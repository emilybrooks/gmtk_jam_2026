extends State

@onready var feet := owner

func _ready() -> void:
	pass

func enter() -> void:
	%LeftShoe.position = %LeftStand.position
	%LeftShoe.rotation = %LeftStand.rotation
	%RightShoe.position = %RightStand.position
	%RightShoe.rotation = %RightStand.rotation

func update(delta: float) -> State:
	if feet.player.velocity.y > 0.0:
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftRise.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftRise.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightRise.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightRise.rotation, 0.1)
	else:
		var left_tween = create_tween()
		var right_tween = create_tween()
		left_tween.tween_property(%LeftShoe, "position", %LeftFall.position, 0.1)
		left_tween.tween_property(%LeftShoe, "rotation", %LeftFall.rotation, 0.1)
		right_tween.tween_property(%RightShoe, "position", %RightFall.position, 0.1)
		right_tween.tween_property(%RightShoe, "rotation", %RightFall.rotation, 0.1)
		
	return null
	
func exit() -> void:
	pass
