extends State

func _ready() -> void:
	pass

func enter() -> void:
	var goal_items = get_tree().get_nodes_in_group("GoalItem")
	for goal_item in goal_items:
		goal_item.enable()

func update(delta: float) -> State:
	return null
	
func exit() -> void:
	pass
