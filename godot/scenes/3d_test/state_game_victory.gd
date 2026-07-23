extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Victory")

	%GameplayUI.hide()
	%ResultsScreen.show()
	%ButtonRetry.grab_focus()

func update(delta: float) -> State:
	return null
	
func exit() -> void:
	%ResultsScreen.hide()
