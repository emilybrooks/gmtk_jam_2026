extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Victory")
	%LabelClearTime.text = %LabelGameTimer.time_to_string(%LabelGameTimer.clear_time)
	%GameplayUI.hide()
	%ResultsScreen.show()
	%ButtonRetry.grab_focus()

func update(delta: float) -> State:
	return null
	
func exit() -> void:
	%ResultsScreen.hide()
