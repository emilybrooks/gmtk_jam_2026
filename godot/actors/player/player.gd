extends Node3D

## meters per second
const SPEED = 7.0

## meters per second per second
const DECELERATION = 1.0 / 3.0

# meters per second per second
const ACCELERATION = 2.0 / 3.0

# meters per second
const SPRING_INITIAL_SPEED = 16.0

# meters per second
const UPDRAFT_TARGET_SPEED = 1.0

# meters per second per second
const UPDRAFT_FALLING_ACCEL = 1.0

# meters per second per second
const UPDRAFT_RISING_ACCEL = 1.0 / 2.0

var move_vector := Vector2.ZERO
var state: State
var previous_position: Vector3
var velocity := Vector3.ZERO
## is the player currently colliding with a wall?
var wall_collision: bool = false
## yaw of the wall the player is colliding with
var wall_yaw: float
## normal of the wall the player is colliding with
var wall_normal: Vector3

# Once the player has double-jumped once in the air, they shouldn't be able to
# double-jump again before they touch the ground. This variable is located in
# the top-level player script so every state has access to it.
var has_double_jumped = false

@onready var spawn_position = position
@onready var ability_double_jump := Ability.new("Double Jump", %PlayerStar.label_3d_double_jump)
@onready var ability_jump := Ability.new("Jump", %PlayerStar.label_3d_jump)
@onready var ability_float := Ability.new("Float", %PlayerStar.label_3d_float)
@onready var ability_spring := Ability.new("Spring", %PlayerStar.label_3d_spring)
@onready var ability_array: Array[Ability] = [ability_spring, ability_double_jump, ability_jump, ability_float]
@onready var chopping_block_ability: String = ability_array[0].name

# the angle of walls can be determined by the y component of their normal
## Degrees.
const WALL_MIN_ANGLE: float = 60
const WALL_MIN_COS: float = cos(deg_to_rad(WALL_MIN_ANGLE))
const WALL_MIN_SIN: float = sin(deg_to_rad(WALL_MIN_ANGLE))
## Degrees.
const WALL_MAX_ANGLE: float = 143
const WALL_MAX_COS: float = cos(deg_to_rad(WALL_MAX_ANGLE))

func change_state(new_state: State) -> void:
	if state:
		state.exit()
	state = new_state
	state.enter()

func _ready() -> void:
	var springs = get_tree().get_nodes_in_group("Spring")
	for spring in springs:
		spring.spring_touched.connect(_on_spring_spring_touched)
	
	var updrafts = get_tree().get_nodes_in_group("Updraft")
	for updraft in updrafts:
		updraft.player_in_updraft.connect(_on_updraft_player_in_updraft)
		
	change_state(%StateGround)

func _input(event: InputEvent) -> void:
	move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			
func _process(delta: float) -> void:
	var new_state = state.update(delta)
	if new_state:
		change_state(new_state)

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var new_state = state.update_physics(delta, space_state)
	if new_state:
		change_state(new_state)

# check for wall collisions, and displace the player's XZ coordinates so that they are radius units away from walls
# returns true if the player collided with a wall triangle
# false otherwise
func check_walls
(
	collision_mesh_vertices: PackedVector3Array,
	wall_check_height: float,
	wall_check_radius: float,
	space_state: PhysicsDirectSpaceState3D
) -> bool:
	var result: bool = false
	var displaced_position: Vector3 = position
	var corner_displacement: Vector3 = Vector3.ZERO
	var stored_yaw_diff: float = 2*PI
	
	# allow walking over steps by checking step height above the player's position
	displaced_position += Vector3.UP * wall_check_height
	
	# iterate through collision triangles to check for walls
	# TODO: this literally checks everything and is not very optimal
	@warning_ignore("integer_division")
	var number_of_triangles: int = collision_mesh_vertices.size() / 3
	
	for i in range(number_of_triangles):
		var vertex0: Vector3 = collision_mesh_vertices[i * 3]
		var vertex1: Vector3 = collision_mesh_vertices[i * 3 + 1]
		var vertex2: Vector3 = collision_mesh_vertices[i * 3 + 2]
	
		var plane = Plane(vertex0, vertex1, vertex2)
		var xz_normal: Vector3 = Vector3(plane.normal.x, 0, plane.normal.z).normalized()

		# ignore triangles that aren't walls
		if  plane.normal.y > WALL_MIN_COS or plane.normal.y < WALL_MAX_COS:
			continue
		
		var distance_to_plane: float = plane.distance_to(displaced_position)
		const behind_radius: float = 0.1
		if distance_to_plane < -behind_radius or distance_to_plane > wall_check_radius:
			# too far away, not colliding
			continue
			
		var plane_closest_point: Vector3 = displaced_position - plane.normal * distance_to_plane
		var barycentric_coords: Vector3 = Geometry3D.get_triangle_barycentric_coords(plane_closest_point, vertex0, vertex1, vertex2)

		if barycentric_coords.x < 0.0 or barycentric_coords.y < 0.0 or barycentric_coords.z < 0.0:
			if result:
				continue
				
			# point is outside triangle, we aren't colliding with this wall triangle
			# but if we haven't collided with a wall yet,
			# there's a chance the player is in a corner between two walls
			# in this case, find the closest point on the edge of the triangle
			# if we're close to this point, we can displace radius units away to smooth out corners
			var c1: Vector3 = Geometry3D.get_closest_point_to_segment(displaced_position, vertex0, vertex1)
			var c2: Vector3 = Geometry3D.get_closest_point_to_segment(displaced_position, vertex1, vertex2)
			var c3: Vector3 = Geometry3D.get_closest_point_to_segment(displaced_position, vertex2, vertex0)

			var c1_distance: float = displaced_position.distance_squared_to(c1)
			var c2_distance: float = displaced_position.distance_squared_to(c2)
			var c3_distance: float = displaced_position.distance_squared_to(c3)

			var closest_point: Vector3
			var corner_radius: float = wall_check_radius
			var corner_radius_squared: float = corner_radius * corner_radius
			# first vertex of the line segment closest point is on
			var p1: Vector3
			# second vertex of the line segment closest point is on
			var p2: Vector3
			
			if c1_distance < corner_radius_squared \
			and c1_distance < c2_distance \
			and c1_distance < c3_distance:
				closest_point = c1
				p1 = vertex0
				p2 = vertex1

			elif c2_distance < corner_radius_squared \
			and c2_distance < c1_distance \
			and c2_distance < c3_distance:
				closest_point = c2
				p1 = vertex1
				p2 = vertex2

			elif c3_distance < corner_radius_squared:
				closest_point = c3
				p1 = vertex2
				p2 = vertex0
			
			else:
				# too far away, ignore this triangle
				continue

			# if edges aren't steep enough to be walls, they will interfere with climbing over steps, so ignore them
			var edge_angle = (p1 - p2).normalized().y
			if edge_angle < WALL_MIN_SIN:
				continue
			
			# displace radius units away from closest point
			var point_to_point: Vector3 = displaced_position - closest_point
			var point_to_point_xz_normal: Vector3 = Vector3(point_to_point.x, 0, point_to_point.z).normalized()
			corner_displacement.x += point_to_point_xz_normal.x * (corner_radius - point_to_point.length())
			corner_displacement.z += point_to_point_xz_normal.z * (corner_radius - point_to_point.length())

		else:
			# point is inside triangle, we are colliding
			result = true

			# displace radius units away from the wall along the xz normal
			displaced_position.x += xz_normal.x * (wall_check_radius - distance_to_plane)
			displaced_position.z += xz_normal.z * (wall_check_radius - distance_to_plane)

			# store properties of the wall the player is colliding with
			# we want to store the wall that's closest to the player's facing angle
			# so we compare the difference between player yaw and wall yaw
			# and only overwrite them if the difference is smaller than the previous wall
			var player_yaw: float = atan2(basis.z.x, basis.z.z)
			var current_wall_yaw: float = atan2(plane.normal.x, plane.normal.z)
			var player_wall_yaw_diff = abs(angle_difference(player_yaw, current_wall_yaw))
			if player_wall_yaw_diff < stored_yaw_diff:
				stored_yaw_diff = player_wall_yaw_diff
				wall_yaw = current_wall_yaw
				wall_normal = plane.normal
	
	position.x = displaced_position.x
	position.z = displaced_position.z
	
	# if the player already collided with a wall, don't apply corner displacement
	# otherwise this will cause problems when sliding along straight walls with multiple edges
	if !result:
		position.x += corner_displacement.x
		position.z += corner_displacement.z
	
	return result

func prevent_tunneling(wall_check_height: float, space_state) -> void:
	var start: Vector3 = previous_position + Vector3.UP * wall_check_height
	var end: Vector3 = position + Vector3.UP * wall_check_height
	var wall_raycast := Raycast3DHelper.new(start, end, space_state)
	
	# if there was a wall that the player clipped past, move back to it
	if wall_raycast.fraction != 1.0:
		position.x = wall_raycast.endpos.x
		position.z = wall_raycast.endpos.z

func current_ability_count() -> int:
	var count = 0
	for ability in ability_array:
		if ability.owned:
			count += 1
	
	return count

func move_horizontally() -> void:
	# controls should be in camera reference frame
	# so convert the joystick direction to the player camera's coordinate system
	# instead of using the camera's basis, construct one from just the camera's azimuth to keep it upright
	var camera_space := Basis.IDENTITY.rotated(Vector3.UP, %Camera.spherical_coords.azimuth)
	var camera_ref_move: Vector3 = camera_space * Vector3(move_vector.x, 0, move_vector.y)
	
	var target_velocity: Vector3 = camera_ref_move * SPEED
	
	var current_horiz_velocity: Vector2 = Vector2(velocity.x, velocity.z)
	var target_horiz_velocity: Vector2 = Vector2(target_velocity.x, target_velocity.z)
	
	if move_vector == Vector2.ZERO:
		current_horiz_velocity = current_horiz_velocity.move_toward(target_horiz_velocity, DECELERATION)
	else:
		current_horiz_velocity = current_horiz_velocity.move_toward(target_horiz_velocity, ACCELERATION)
		
	velocity.x = current_horiz_velocity.x
	velocity.z = current_horiz_velocity.y

		
func _on_timer_timeout():
	# disable the highest priority ability
	for ability_index in range(ability_array.size()):
		if ability_array[ability_index].owned == true:
			ability_array[ability_index].disable()
			
			if ability_index == ability_array.size() - 1:
				change_state(%StateFlop)
				%LabelClock.hide()
			else:
				chopping_block_ability = ability_array[ability_index + 1].name
			
			break
		
	#for ability in ability_array:
		#if ability.owned == true:
			#ability.disable()
			#break
	#
	#if current_ability_count() == 0:
		#change_state(%StateFlop)

func _on_game_init() -> void:
	position = spawn_position
	velocity = Vector3.ZERO
	%Camera.spherical_coords.azimuth = 0.0
	for ability in ability_array:
		ability.enable()
	
func _on_game_start() -> void:
	change_state(%StateGround)

func _on_victory() -> void:
	change_state(%StateVictory)

func _on_spring_spring_touched() -> void:
	change_state(%StateAir)
	velocity.y = SPRING_INITIAL_SPEED
	
func _on_updraft_player_in_updraft() -> void:
	change_state(%StateAir)
	
	# Gradually move the player's y-velocity to a specific slow value
	var current_velocity = Vector3(0, velocity.y, 0)
	var target_velocity = Vector3(0, UPDRAFT_TARGET_SPEED, 0)
	
	# If the player is falling into an updraft, it feels weird if the updraft doesn't immediately
	# push back on them. However, once they're no longer falling, we want the acceleration to be
	# painfully slow to make the updraft feel suboptimal.
	if (velocity.y < 0.0):
		current_velocity = current_velocity.move_toward(target_velocity, UPDRAFT_FALLING_ACCEL)
	else:
		current_velocity = current_velocity.move_toward(target_velocity, UPDRAFT_RISING_ACCEL)
	
	velocity.y = current_velocity.y
