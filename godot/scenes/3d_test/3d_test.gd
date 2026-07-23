extends Node3D

signal game_init
signal game_start
signal victory

var state: State

func change_state(new_state: State) -> void:
	if state:
		state.exit()
	state = new_state
	state.enter()

func _ready() -> void:
	var goal_items = get_tree().get_nodes_in_group("GoalItem")
	for goal_item in goal_items:
		goal_item.goal_item_collected.connect(%LabelScore._on_goal_item_collected)
		
	change_state(%StateGameInit)

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

func _on_gate_gate_complete() -> void:
	victory.emit()
	change_state($StateGameVictory)

func _on_gate_gate_enabled() -> void:
	$%LabelGateDebug.text = "Gate Status: Enabled"

func _on_button_retry_pressed() -> void:
	change_state($StateGameInit)
