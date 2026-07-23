extends Control

func _on_score_item_collected() -> void:
	%LabelScoreNumber.add_points(1)


func _on_goal_goal_entered() -> void:
	$LabelGoalDebug.text = "Goal state: player entered"
