extends Node3D

var not_ready_material = preload("res://actors/gate/gate_not_ready_material_3d.tres")
var ready_material = preload("res://actors/gate/gate_ready_material_3d.tres")

enum State {
	Disabled, # The player has not collected all of the goal items yet. Entering the gate does nothing
	Ready,    # The player has collected all of the goal items. Entering the gate completes the game
	Complete  # The player has entered the gate with the goal items. The game is over
}

var current_state = State.Disabled
var collected_goals = []

signal gate_ready
signal gate_complete
signal gate_entered

func _ready() -> void:
	current_state = State.Disabled
			
func _process(delta: float) -> void:
	pass

func set_to_ready() -> void:
	$MeshInstance3D.mesh.set_material(ready_material)
	current_state = State.Ready
	gate_ready.emit()

func set_to_complete() -> void:
	current_state = State.Complete
	gate_complete.emit()

func is_goal_ready() -> bool:
	# This is kind of dumb but it should work assuming we always put exactly five goals in the level
	return collected_goals.size() == 5

func _on_area_3d_area_entered(area: Area3D) -> void:
	gate_entered.emit()
	if current_state == State.Ready:
		set_to_complete()

func _on_goal_item_goal_item_collected(number: int) -> void:
	collected_goals.append(number)
	if (is_goal_ready()):
		set_to_ready()
