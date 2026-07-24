extends State

const WALK_CYCLE_TIME = 0.45

var elapsed_time = 0.0

func _ready() -> void:
	pass

func enter() -> void:
	%LeftShoe.position = %LeftStand.position
	%LeftShoe.rotation = %LeftStand.rotation
	%RightShoe.position = %RightStand.position
	%RightShoe.rotation = %RightStand.rotation

func update(delta: float) -> State:
	elapsed_time += delta
	if (elapsed_time >= WALK_CYCLE_TIME):
		elapsed_time = 0.0
	
	if elapsed_time < (1 * WALK_CYCLE_TIME / 4):
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftForward.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftForward.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightBack.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightBack.rotation, 0.1)
	elif elapsed_time < (2 * WALK_CYCLE_TIME / 4):
		%FootstepSound.play()
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftStand.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftStand.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightStand.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightStand.rotation, 0.1)
	elif elapsed_time < (3 * WALK_CYCLE_TIME / 4):
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftBack.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftBack.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightForward.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightForward.rotation, 0.1)
	else:
		%FootstepSound.play()
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftStand.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftStand.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightStand.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightStand.rotation, 0.1)
		
	return null
	
func exit() -> void:
	pass
