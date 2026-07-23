extends Node3D

signal goal_entered

func _ready() -> void:
	pass
			
func _process(delta: float) -> void:
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	goal_entered.emit()
