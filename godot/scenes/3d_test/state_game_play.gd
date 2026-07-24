extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Play")
	owner.game_start.emit()
	%LabelClock.show()

func update(delta: float) -> State:
	return null
	
func exit() -> void:
	pass
