extends Node3D

signal goal_item_collected(number)

@export var number = 1
var stream = null

func _ready() -> void:
	$Label3D.text = "%d" % number
	if (number > 0 and number < 10):
		stream = load("res://assets/audio/count_%d.ogg" % number)

func _on_area_3d_area_entered(area: Area3D) -> void:
	goal_item_collected.emit(number)
	$NumberSound.stream = stream
	$NumberSound.play()
	disable()

func enable() -> void:
	visible = true
	%Area3D.set_collision_mask_value(2, true)
	
func disable() -> void:
	visible = false
	%Area3D.set_collision_mask_value(2, false)
