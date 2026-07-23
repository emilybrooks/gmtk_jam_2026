extends Node3D

signal clock_item_collected
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	clock_item_collected.emit()
	disable()

func enable() -> void:
	visible = true
	%Area3D.set_collision_mask_value(2, true)
	
func disable() -> void:
	visible = false
	%Area3D.set_collision_mask_value(2, false)
