extends Node3D

signal clock_item_collected
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	clock_item_collected.emit()
	queue_free()
