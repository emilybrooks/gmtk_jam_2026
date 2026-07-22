extends Node3D

func _ready() -> void:
	var score_items = get_tree().get_nodes_in_group("ScoreItem")
	for score_item in score_items:
		score_item.score_item_collected.connect(%GameplayUI._on_score_item_collected)
