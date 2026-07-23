extends State

@onready var player := owner

## how high above the ground to check for walls. influences how tall of a step you can climb up
const WALL_CHECK_HEIGHT = 0.41 # 16 hammer units

## how far away to push the player away from walls
const WALL_CHECK_RADIUS: float = 0.4

## meters. vertical offset from the player's position to start a raycast from that looks for the floor.
const FLOOR_CHECK_START = 1.0

## meters. distance below the player to check for a floor
const FLOOR_CHECK_END = 0.1

## meters per second per second, should be multiplied by delta
const GRAVITY: float = -9.8

# meters per second
const DOUBLE_JUMP_INITIAL_SPEED: float = 6.0

# Once the player has double-jumped once in the air, they shouldn't be able to double-jump again
var has_double_jumped = false

func _ready() -> void:
	pass

func enter() -> void:
	has_double_jumped = false

func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	if (player.velocity.y < 3.0):
		if Input.is_action_pressed("jump") and player.ability_double_jump.owned and !has_double_jumped:
			print("jump pressed in air")
			player.velocity.y = DOUBLE_JUMP_INITIAL_SPEED
			has_double_jumped = true
	
	player.previous_position = player.position

	player.velocity -= Vector3.DOWN * GRAVITY * delta
	
	player.move_horizontally()
	
	# move
	player.position = player.position + player.velocity * delta

	# wall collision
	player.prevent_tunneling(WALL_CHECK_HEIGHT, space_state)
	var map_collision_faces: PackedVector3Array = get_tree().get_nodes_in_group("MapCollision")[0].get_child(0).shape.get_faces()
	player.wall_collision = player.check_walls(map_collision_faces, WALL_CHECK_HEIGHT, WALL_CHECK_RADIUS, space_state)
	
	# find floor
	var start: Vector3 = player.position + Vector3.UP * FLOOR_CHECK_START
	var end: Vector3 = player.position + Vector3.DOWN * FLOOR_CHECK_END
	var floor_raycast := Raycast3DHelper.new(start, end, space_state)
	if floor_raycast.fraction != 1.0:
		if player.current_ability_count() <= 0:
			return %StateFlop
		else:
			return %StateGround
	
	return null
	
func exit() -> void:
	pass
