extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Play")
	owner.game_start.emit()
	%LabelClock.show()

func update(delta: float) -> State:
	if Input.is_action_pressed("retry"):
		return %StateGameInit
	return null
	
func exit() -> void:
	pass
