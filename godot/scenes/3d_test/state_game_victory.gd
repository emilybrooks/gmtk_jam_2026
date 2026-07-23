extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Victory")
	$%LabelGateDebug.text = "Gate Status: Complete"
	$%LabelYouWon.visible = true
	%ButtonRetry.show()
	%ButtonRetry.grab_focus()

func update(delta: float) -> State:
	return null
	
func exit() -> void:
	pass
