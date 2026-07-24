extends State

## meters per second
const SPEED = 2.0

## meters per second per second
const DECELERATION = 1.0 / 3.0

## meters. vertical offset from the player's position to start a raycast from that looks for the floor.
const FLOOR_CHECK_HEIGHT = 1.0

## meters. where the floor check raycast will end
const FLOOR_LOWER_LIMIT = -1000.0

## how high above the ground to check for walls. influences how tall of a step you can climb up
const WALL_CHECK_HEIGHT = 0.41 # 16 hammer units

## how far away to push the player away from walls
const WALL_CHECK_RADIUS: float = 0.4

# meters per second
const JUMP_INITIAL_SPEED: float = 3.0

@onready var player := owner

func _ready() -> void:
	pass

func enter() -> void:
	%PlayerStar.flop = true
	# In practice, this should basically do nothing. If the player is flopping,
	# we took away their double jump. But for consistency, they touched the
	# ground, so let's give them back the ability to double jump.
	player.has_double_jumped = false

func update(delta: float) -> State:
	return null
	
func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	player.previous_position = player.position
	
	# get velocity
	# controls should be in camera reference frame
	# so convert the joystick direction to the player camera's coordinate system
	
	# instead of using the camera's basis, construct one from just the camera's azimuth to keep it upright
	var camera_space := Basis.IDENTITY.rotated(Vector3.UP, %Camera.spherical_coords.azimuth)
	var camera_ref_move: Vector3 = camera_space * Vector3(player.move_vector.x, 0, player.move_vector.y)
	
	var new_velocity: Vector3 = camera_ref_move * SPEED
	
	if player.move_vector == Vector2.ZERO:
		# decelerate
		player.velocity = player.velocity.move_toward(new_velocity, DECELERATION)
	else:
		player.velocity = new_velocity
	
	# wall collision
	player.prevent_tunneling(WALL_CHECK_HEIGHT, space_state)
	var map_collision_faces: PackedVector3Array = get_tree().get_nodes_in_group("MapCollision")[0].get_child(0).shape.get_faces()
	player.wall_collision = player.check_walls(map_collision_faces, WALL_CHECK_HEIGHT, WALL_CHECK_RADIUS, space_state)
	
	# find floor
	var start: Vector3 = player.position + Vector3.UP * FLOOR_CHECK_HEIGHT
	var end: Vector3 = Vector3(player.position.x, FLOOR_LOWER_LIMIT, player.position.z)
	var floor_raycast := Raycast3DHelper.new(start, end, space_state)
	
	var current_floor_y: float = floor_raycast.endpos.y
	var floor_height_difference: float = current_floor_y - player.previous_position.y
	
	if floor_height_difference >= 0:
		# player is below the floor
		player.position.y = current_floor_y
	
	if new_velocity.length() != 0.0:
		# jump if the player is moving
		player.velocity.y = JUMP_INITIAL_SPEED
		return %StateAir
	else:
		return null
	
func exit() -> void:
	pass
