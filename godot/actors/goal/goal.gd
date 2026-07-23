extends Node3D

var not_ready_material = preload("res://actors/goal/goal_not_ready_material_3d.tres")
var ready_material = preload("res://actors/goal/goal_ready_material_3d.tres")

enum State {
	Disabled, # The player has not collected the goal item yet. Entering the goal does nothing
	Ready,    # The player has collected the goal item. Entering the goal completes the game
	Complete  # The player has entered the goal with the goal item. The game is over
}

var current_state = State.Disabled

signal goal_ready
signal goal_complete
signal goal_entered

func _ready() -> void:
	current_state = State.Disabled
			
func _process(delta: float) -> void:
	pass

func set_to_ready() -> void:
	$MeshInstance3D.mesh.set_material(ready_material)
	current_state = State.Ready
	goal_ready.emit()

func set_to_complete() -> void:
	current_state = State.Complete
	goal_complete.emit()

func _on_area_3d_area_entered(area: Area3D) -> void:
	goal_entered.emit()
	if current_state == State.Ready:
		set_to_complete()
		goal_complete.emit()

func _on_score_item_score_item_collected() -> void:
	set_to_ready()
