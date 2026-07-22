class_name State extends Node
## A state for use in a finite state machine

## This function runs once when switching to this state
func enter() -> void:
	pass

## Per state input handling. Return null to continue with this state, or a different state to switch to it
func input(event: InputEvent) -> State:
	return null
	
## Per state _process(). Return null to continue with this state, or a different state to switch to it
func update(delta: float) -> State:
	return null
	
## Per state _physics_process(). Return null to continue with this state, or a different state to switch to it
func update_physics(delta: float, space_state: PhysicsDirectSpaceState3D) -> State:
	return null

## This function runs once when switching to a different state
func exit() -> void:
	pass
