extends State

## meters per second
const SPEED = 5.0

## meters per second per second
const DECELERATION = 1.0 / 3.0

## meters. vertical offset from the player's position to start a raycast from that looks for the floor.
const FLOOR_CHECK_HEIGHT = 1.0

## meters. where the floor check raycast will end
const FLOOR_LOWER_LIMIT = -1000.0

## how high the player is allowed to be above the floor without falling. eg, going down a ramp should snap you to the floor
const FLOOR_SNAP_HEIGHT = 0.41

## how high above the ground to check for walls. influences how tall of a step you can climb up
const WALL_CHECK_HEIGHT = 0.41 # 16 hammer units

## how far away to push the player away from walls
const WALL_CHECK_RADIUS: float = 0.4

# meters per second
const JUMP_INITIAL_SPEED: float = 6.0

@onready var player := owner

func _ready() -> void:
	pass

func enter() -> void:
	pass

func update(delta: float) -> State:
	return null
	
func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	if Input.is_action_pressed("jump"):
		player.velocity.y = JUMP_INITIAL_SPEED
		return %StateAir
	
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
	
	# move
	player.position = player.position + player.velocity * delta
	
	# wall collision
	player.prevent_tunneling(WALL_CHECK_HEIGHT, space_state)
	var map_collision_faces: PackedVector3Array = get_tree().get_nodes_in_group("MapCollision")[0].get_child(0).shape.get_faces()
	player.wall_collision = player.check_walls(map_collision_faces, WALL_CHECK_HEIGHT, WALL_CHECK_RADIUS, space_state)
	
	 # actor collision
	var actor_collision_nodes = get_tree().get_nodes_in_group("ActorCollision")
	for actor in actor_collision_nodes:
		# offset collision vertices by the actor's world position
		var actor_collision_faces: PackedVector3Array = actor.collision_mesh.get_faces()
		for i in range(actor_collision_faces.size()):
			actor_collision_faces[i] += actor.position
			
		var collision: bool = player.check_walls(actor_collision_faces, WALL_CHECK_HEIGHT, WALL_CHECK_RADIUS, space_state)
		if collision:
			actor.on_player_wall_collision(player, delta)
			
	
	# find floor
	var start: Vector3 = player.position + Vector3.UP * FLOOR_CHECK_HEIGHT
	var end: Vector3 = Vector3(player.position.x, FLOOR_LOWER_LIMIT, player.position.z)
	var floor_raycast := Raycast3DHelper.new(start, end, space_state)
	
	var current_floor_y: float = floor_raycast.endpos.y
	var floor_height_difference: float = current_floor_y - player.previous_position.y
	
	if floor_height_difference >= 0:
		# player is below the floor
		player.position.y = current_floor_y
	
	elif floor_height_difference > -FLOOR_SNAP_HEIGHT:
		# player is above the floor, within snapping range
		player.position.y = current_floor_y
	
	else:
		return %StateAir
	
	return null
	
func exit() -> void:
	pass
