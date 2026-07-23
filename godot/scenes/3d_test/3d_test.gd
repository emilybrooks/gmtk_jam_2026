extends Node3D

func _ready() -> void:
	var goal_items = get_tree().get_nodes_in_group("GoalItem")
	for goal_item in goal_items:
		goal_item.goal_item_collected.connect(%LabelScore._on_goal_item_collected)
	


func _on_gate_gate_ready() -> void:
	$%LabelGateDebug.text = "Gate Status: Ready"


func _on_gate_gate_complete() -> void:
	$%LabelGateDebug.text = "Gate Status: Complete"
	$%LabelYouWon.visible = true
