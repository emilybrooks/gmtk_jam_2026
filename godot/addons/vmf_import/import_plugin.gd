@tool
extends EditorImportPlugin

enum CollisionType {CONVEX, CONCAVE}
var missing_material: bool = false

func _get_importer_name() -> String:
	# unique name
	return "vmfimport"
	
func _get_visible_name() -> String:
	# shown in the import dock
	return "VMF Scene"
	
func _get_recognized_extensions() -> PackedStringArray:
	return ["vmf"]

func _get_save_extension() -> String:
	return "tscn"

func _get_resource_type() -> String:
	return "PackedScene"

# don't use presets
func _get_preset_count() -> int:
	return 0

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return [
				{
					"name": "material_directory",
					"default_value": "res://assets/materials",
				},
				{
					"name": "hammer_units_per_meter",
					"default_value": 40,
					"property_hint": PROPERTY_HINT_RANGE,
					"hint_string": "0,1024",
				},
				{
					"name": "collision_type",
					"default_value": CollisionType.CONVEX,
					"property_hint": PROPERTY_HINT_ENUM ,
					"hint_string": "Convex,Concave",
				},
			]
	
const VMFParser = preload("./parse_vmf.gd")
const DEBUGEMPTY = preload("uid://cytorrbhmk76s")

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	# read file
	var world: Array
	while file.get_position() < file.get_length():
		var line = file.get_line()
		if line == "world":
			world = VMFParser.parse_world(file)
	
	var root: Node3D
	match options.collision_type:
		CollisionType.CONVEX:
			root = convex_collision(world, options)
		CollisionType.CONCAVE:
			root = concave_collision(world, options)
			
	root.name = source_file.get_file()
	
	var scene = PackedScene.new()
	scene.pack(root)
	
	if missing_material:
		printerr("[VMF Import] One or more materials were not found. Check that the Material Directory specified in the import dock is correct.")
		
	return ResourceSaver.save(scene, "%s.%s" % [save_path, _get_save_extension()])

## Returns a Node3D that contains all the level geometry and collision as child nodes.
## Collision consists of separate convex collision shapes for every brush
func convex_collision(world: Array, options: Dictionary) -> Node3D:
	var root := Node3D.new()
	
	var static_body_3d := StaticBody3D.new()
	static_body_3d.name = "Collision"
	# add the collision node to a group so that other nodes can easily access it
	static_body_3d.add_to_group("MapCollision", true)
	root.add_child(static_body_3d)
	static_body_3d.owner = root
	
	# iterate over every single brush in the vmf file
	for solid in world:
		# store unique vertices in an array to create a collider for the entire brush
		var points: PackedVector3Array = []
		var vertex_cache = []
		
		for side in solid:
			if side.material_path == "TOOLS/TOOLSNODRAW":
				# skip this side
				# but we still need to add the vertices for collision
				for vertex in side.vertices:
					var adjusted_vertex = Vector3(vertex.x, vertex.z, -1 * vertex.y) / float(options.hammer_units_per_meter)
					var hash = hash(adjusted_vertex)
					if not hash in vertex_cache:
						vertex_cache.append(hash)
						points.append(adjusted_vertex)
						
				continue
			
			# side that doesn't have nodraw:
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			
			var absolute_material_path: String = options.material_directory.path_join(side.material_path.to_lower()) + ".tres"
			var material: StandardMaterial3D = load(absolute_material_path)
			if material == null:
				missing_material = true
				material = DEBUGEMPTY
				
			st.set_material(material)
			
			var texture_width = material.albedo_texture.get_width()
			var texture_height = material.albedo_texture.get_height()
				
			for vertex in side.vertices:
				# calculate uv coordinates
				var u = (vertex.dot(side.u_vector) + side.u_shift * side.u_scale) / texture_width / side.u_scale;
				var v = (vertex.dot(side.v_vector) + side.v_shift * side.v_scale) / texture_height / side.v_scale;
				st.set_uv(Vector2(u, v))
				
				# hammer Z axis up
				# godot y axis up
				var adjusted_vertex = Vector3(vertex.x, vertex.z, -1 * vertex.y) / float(options.hammer_units_per_meter)
				st.add_vertex(adjusted_vertex)
				
				# only add unique vertices to the collision shape points
				var hash = hash(adjusted_vertex)
				if not hash in vertex_cache:
					vertex_cache.append(hash)
					points.append(adjusted_vertex)
				
			# create the mesh with fan triangulation
			# vertex 0 is the common vertex
			var tri_count = side.vertices.size() - 2
			for i in range(tri_count):
				st.add_index(0)
				st.add_index(i + 1)
				st.add_index(i + 2)
			
			st.generate_normals()
			var mesh := st.commit()
			
			var mesh_instance_3d = MeshInstance3D.new()
			mesh_instance_3d.mesh = mesh
			
			root.add_child(mesh_instance_3d)
			mesh_instance_3d.owner = root
		
		# create this brush's collision shape
		if points.size() > 0:
			var convex_shape := ConvexPolygonShape3D.new()
			convex_shape.points = points
			var collision_shape_3d := CollisionShape3D.new()
			collision_shape_3d.shape = convex_shape
			static_body_3d.add_child(collision_shape_3d)
			collision_shape_3d.owner = root
	
	return root

## Returns a Node3D that contains all the level geometry and collision as child nodes.
## Collision is a single concave collision mesh
func concave_collision(world: Array, options: Dictionary) -> Node3D:
	var root := Node3D.new()
	var collision_triangles: PackedVector3Array = []

	var static_body_3d := StaticBody3D.new()
	static_body_3d.name = "Collision"
	# add the collision node to a group so that other nodes can easily access it
	static_body_3d.add_to_group("MapCollision", true)
	root.add_child(static_body_3d)
	static_body_3d.owner = root
	
	# iterate over every single brush in the vmf file
	for solid in world:
		for side in solid:
			if side.material_path == "TOOLS/TOOLSNODRAW":
				# don't create meshes for these
				# but we still need to add the vertices to the collision mesh
				var stored_vertices: PackedVector3Array = []
				for vertex in side.vertices:
					var adjusted_vertex = Vector3(vertex.x, vertex.z, -1 * vertex.y) / float(options.hammer_units_per_meter)
					stored_vertices.append(adjusted_vertex)
					
				var tri_count = side.vertices.size() - 2
				for i in range(tri_count):
					collision_triangles.append(stored_vertices[0])
					collision_triangles.append(stored_vertices[i + 1])
					collision_triangles.append(stored_vertices[i + 2])
			else:
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				
				var absolute_material_path: String = options.material_directory.path_join(side.material_path.to_lower()) + ".tres"
				var material: StandardMaterial3D = load(absolute_material_path)
				if material == null:
					missing_material = true
					material = DEBUGEMPTY
					
				st.set_material(material)
				
				var texture_width = material.albedo_texture.get_width()
				var texture_height = material.albedo_texture.get_height()
				
				var stored_vertices: PackedVector3Array = []
				for vertex in side.vertices:
					# calculate uv coordinates
					var u = (vertex.dot(side.u_vector) + side.u_shift * side.u_scale) / texture_width / side.u_scale;
					var v = (vertex.dot(side.v_vector) + side.v_shift * side.v_scale) / texture_height / side.v_scale;
					st.set_uv(Vector2(u, v))
					
					# hammer Z axis up
					# godot y axis up
					var adjusted_vertex = Vector3(vertex.x, vertex.z, -1 * vertex.y) / float(options.hammer_units_per_meter)
					st.add_vertex(adjusted_vertex)
					stored_vertices.append(adjusted_vertex)
					
				# create the mesh with fan triangulation
				# vertex 0 is the common vertex
				var tri_count = side.vertices.size() - 2
				for i in range(tri_count):
					st.add_index(0)
					st.add_index(i + 1)
					st.add_index(i + 2)
					
					# add to collision mesh
					collision_triangles.append(stored_vertices[0])
					collision_triangles.append(stored_vertices[i + 1])
					collision_triangles.append(stored_vertices[i + 2])
					
				st.generate_normals()
				var mesh := st.commit()
			
				var mesh_instance_3d = MeshInstance3D.new()
				mesh_instance_3d.mesh = mesh
				
				root.add_child(mesh_instance_3d)
				mesh_instance_3d.owner = root
		
	# create collision mesh from triangles
	var concave_shape := ConcavePolygonShape3D.new()
	concave_shape.set_faces(collision_triangles)
	var collision_shape_3d := CollisionShape3D.new()
	collision_shape_3d.shape = concave_shape
	static_body_3d.add_child(collision_shape_3d)
	collision_shape_3d.owner = root
	
	return root
