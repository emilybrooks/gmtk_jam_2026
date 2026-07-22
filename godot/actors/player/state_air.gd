extends State

@onready var player := owner

## how high above the ground to check for walls. influences how tall of a step you can climb up
const WALL_CHECK_HEIGHT = 0.41 # 16 hammer units

## how far away to push the player away from walls
const WALL_CHECK_RADIUS: float = 0.4

## meters. vertical offset from the player's position to start a raycast from that looks for the floor.
const FLOOR_CHECK_HEIGHT = 1.0

## meters. where the floor check raycast will end
const FLOOR_LOWER_LIMIT = -1000.0

## how high the player is allowed to be above the floor without falling. eg, going down a ramp should snap you to the floor
const FLOOR_SNAP_HEIGHT = 0.41

## meters per second, should be multiplied by delta
const GRAVITY: float = -9.8

func _ready() -> void:
	pass

func enter() -> void:
	pass

func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	player.previous_position = player.position

	player.velocity -= Vector3.DOWN * GRAVITY * delta
	
	# move
	player.position = player.position + player.velocity * delta

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
	
	if floor_height_difference >= 0 or floor_height_difference > -FLOOR_SNAP_HEIGHT:
		player.position.y = current_floor_y
		return %StateGround
	
	return null
	
func exit() -> void:
	pass
