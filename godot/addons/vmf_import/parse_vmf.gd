# parse_vmf.gd
# reads data from a Hammer++ .vmf file

static func parse_world(file: FileAccess) -> Array:
	var solids: Array = []
	
	while true:
		var line = file.get_line()
		line = line.lstrip("	")
		
		if line == "}":
			break
			
		if line == "solid":
			var solid = parse_solid(file)
			solids.append(solid)
			
	return solids

static func parse_solid(file: FileAccess) -> Array:
	var sides: Array = []
	
	while true:
		var line = file.get_line()
		line = line.lstrip("	")
		
		if line == "}":
			break
			
		if line == "side":
			var side = parse_side(file)
			sides.append(side)
		
		if line == "editor":
			parse_editor(file)
			
	return sides
	
static func parse_side(file: FileAccess) -> Dictionary:
	file.get_line() # skip over the {

	var key_values = {}
	var vertices: Array = []
	
	while true:
		var line = file.get_line()
		line = line.lstrip("	")
		
		if line == "}":
			break
			
		if line == "vertices_plus":
			vertices = parse_vertices(file)
		
		else:
			# key values are formatted as "key" "value"
			var split: PackedStringArray = line.split('" "')
			var key: String = split[0].substr(1)
			var value: String = split[1].substr(0, split[1].length() - 1)
			key_values[key] = value
	
	# vertices_plus is only added by hammer++
	# so if someone tries to load a vmf made by regular hammer no vertices will be added
	assert(vertices.size() > 0)
	
	var side: Dictionary = {}
	side.vertices = vertices
	side.material_path = key_values["material"]
	
	# remove [ and ], values are separated by spaces
	var u_axis: PackedFloat64Array = key_values["uaxis"].remove_char(91).remove_char(93).split_floats(" ")
	side.u_vector = Vector3(u_axis[0], u_axis[1], u_axis[2])
	side.u_shift = u_axis[3]
	side.u_scale = u_axis[4]
	
	var v_axis: PackedFloat64Array = key_values["vaxis"].remove_char(91).remove_char(93).split_floats(" ")
	side.v_vector = Vector3(v_axis[0], v_axis[1], v_axis[2])
	side.v_shift = v_axis[3]
	side.v_scale = v_axis[4]
	
	return side
	
static func parse_vertices(file: FileAccess) -> Array:
	file.get_line() # skip over the {
	
	var vertices: Array
	
	while true:
		var line = file.get_line()
		line = line.lstrip("	")
		
		if line == "}":
			break
		
		else:
			# vertices are formated as "v" "x y z"
			var vertex_string: String = line.substr(5)
			vertex_string = vertex_string.substr(0, vertex_string.length() - 1)
			var vertex_floats: PackedFloat64Array = vertex_string.split_floats(" ")
			vertices.append(Vector3(vertex_floats[0], vertex_floats[1], vertex_floats[2]))
			
	return vertices

# we don't need any data from these, just need to get to the end of a solid definition
static func parse_editor(file: FileAccess) -> void:
	while true:
		var line = file.get_line()
		line = line.lstrip("	")
		if line == "}":
			break
			
