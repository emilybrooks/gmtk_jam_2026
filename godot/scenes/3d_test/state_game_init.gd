extends State

func _ready() -> void:
	pass

func enter() -> void:
	print("Game Init")
	owner.game_init.emit()
	
	var goal_items = get_tree().get_nodes_in_group("GoalItem")
	for goal_item in goal_items:
		goal_item.enable()
	
	var clock_items = get_tree().get_nodes_in_group("ClockItem")
	for clock_item in clock_items:
		clock_item.enable()
		
	%LabelInstructions1.show()
	%LabelInstructions2.hide()
	%LabelClock.hide()
	%GameplayUI.show()
	
func update(delta: float) -> State:
	return null
	
func exit() -> void:
	%LabelInstructions1.hide()
