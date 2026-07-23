extends Label

var score: int = 0

# TODO this is bad!!! We have two sources of the same information. Only one of these should exist, and the UI probably shouldn't be the one that holds it
var collected_goals = []

func _ready() -> void:
	update_label()

func update_label() -> void:
	text = "[%s]" % ", ".join(collected_goals)

func _on_goal_item_collected(number: int) -> void:
	collected_goals.append(number)
	update_label()
	
