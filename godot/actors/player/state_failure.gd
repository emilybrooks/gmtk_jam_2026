extends State

func _ready() -> void:
	pass

func enter() -> void:
	owner.hide()
	
func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	return null
	
func exit() -> void:
	owner.show()
