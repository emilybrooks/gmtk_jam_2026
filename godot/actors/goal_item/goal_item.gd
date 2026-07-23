extends Node3D

signal goal_item_collected(number)

@export var number = 1

func _on_area_3d_area_entered(area: Area3D) -> void:
	goal_item_collected.emit(number)
	queue_free()
