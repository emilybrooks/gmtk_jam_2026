extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Failure")
	%GameplayUI.hide()
	%FailureScreen.show()
	%ButtonRetry.show()
	%ButtonRetry.grab_focus()
	
func input(event: InputEvent) -> State:
	return null

func update(delta: float) -> State:
	return null
	
func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	return null
	
func exit() -> void:
	%FailureScreen.hide()
	%ButtonRetry.hide()
