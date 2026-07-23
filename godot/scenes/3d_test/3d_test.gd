extends Node3D

func _ready() -> void:
	var score_items = get_tree().get_nodes_in_group("ScoreItem")
	for score_item in score_items:
		score_item.score_item_collected.connect(%LabelScore._on_score_item_collected)
	


func _on_goal_goal_ready() -> void:
	$%LabelGoalDebug.text = "Goal Status: Ready"


func _on_goal_goal_complete() -> void:
	$%LabelGoalDebug.text = "Goal Status: Complete"
	$%LabelYouWon.visible = true
