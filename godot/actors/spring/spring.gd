extends Node3D

signal spring_touched

@onready var can_bounce = true

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	if (can_bounce):
		spring_touched.emit()
		$CooldownTimer.start()
		can_bounce = false


func _on_cooldown_timer_timeout() -> void:
	print("cooldown done")
	can_bounce = true
