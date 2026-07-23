extends Label

var score: int = 0

func _ready() -> void:
	update_label()

func update_label() -> void:
	text = "[%s]" % ", ".join(%Gate.collected_goals)

func _on_goal_item_collected(number: int) -> void:
	update_label()

func _on_game_init() -> void:
	text = "[]"
		
