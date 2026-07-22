# meta-description: Base template for setting up a finite state machine

extends _BASE_

var state: State

func change_state(new_state: State) -> void:
	if state:
		state.exit()
	state = new_state
	state.enter()

func _ready() -> void:
	change_state()

func _input(event: InputEvent) -> void:
	var new_state = state.input(event)
	if new_state:
		change_state(new_state)
			
func _process(delta: float) -> void:
	var new_state = state.update(delta)
	if new_state:
		change_state(new_state)

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var new_state = state.update_physics(delta, space_state)
	if new_state:
		change_state(new_state)
