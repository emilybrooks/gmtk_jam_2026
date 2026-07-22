extends Label

var score: int = 0

func _ready() -> void:
	update_label()

func update_label() -> void:
	text = "%d" % score

func add_points(points_to_add: int) -> void:
	score += points_to_add
	update_label()
