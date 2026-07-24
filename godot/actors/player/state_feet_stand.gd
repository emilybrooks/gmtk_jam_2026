extends State

func _ready() -> void:
	pass

func enter() -> void:
	pass

func update(delta: float) -> State:
	var left_tween = create_tween()
	var right_tween = create_tween()
	left_tween.tween_property(%LeftShoe, "position", %LeftStand.position, 0.1)
	left_tween.tween_property(%LeftShoe, "rotation", %LeftStand.rotation, 0.1)
	right_tween.tween_property(%RightShoe, "position", %RightStand.position, 0.1)
	right_tween.tween_property(%RightShoe, "rotation", %RightStand.rotation, 0.1)
	return null
	
func exit() -> void:
	pass
