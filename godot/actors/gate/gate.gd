extends Node3D

var disabled_material = preload("res://actors/gate/gate_disabled_material_3d.tres")
var enabled_material = preload("res://actors/gate/gate_enabled_material_3d.tres")

enum State {
	Disabled, # The player has not collected all of the goal items yet. Entering the gate does nothing
	Enabled,  # The player has collected all of the goal items. Entering the gate completes the game
	Complete  # The player has entered the gate with the goal items. The game is over
}

var current_state = State.Disabled
var collected_goals = []

signal gate_enabled
signal gate_complete
signal gate_entered

func _ready() -> void:
	current_state = State.Disabled
	$MeshInstance3D.mesh.set_material(disabled_material)

func _process(delta: float) -> void:
	pass

func set_to_enabled() -> void:
	$MeshInstance3D.mesh.set_material(enabled_material)
	current_state = State.Enabled
	gate_enabled.emit()

func set_to_complete() -> void:
	current_state = State.Complete
	gate_complete.emit()

func is_goal_enabled() -> bool:
	# This is kind of dumb but it should work assuming we always put exactly five goals in the level
	return collected_goals.size() == 5

func _on_area_3d_area_entered(area: Area3D) -> void:
	gate_entered.emit()
	if current_state == State.Enabled:
		set_to_complete()

func _on_goal_item_goal_item_collected(number: int) -> void:
	collected_goals.append(number)
	if (is_goal_enabled()):
		set_to_enabled()
