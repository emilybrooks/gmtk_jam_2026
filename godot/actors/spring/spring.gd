extends Node3D

signal spring_touched

@onready var bounce_cooldown = false
@onready var squash_and_stretch = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if squash_and_stretch:
		var ratio = $SquashAndStretchTimer.time_left / $SquashAndStretchTimer.wait_time
		var angle = 6 * PI * ratio
		var horiz_scale = 0.4 * cos(angle)
		var vert_scale = 0.6 * sin(angle)

		$Area3D.scale.x = 1.0 + (horiz_scale * ratio)
		$Area3D.scale.z = 1.0 + (horiz_scale * ratio)
		$Area3D.scale.y = 1.0 + (vert_scale * ratio)
	else:
		$Area3D.scale.x = 1.0
		$Area3D.scale.z = 1.0
		$Area3D.scale.y = 1.0

func _on_area_3d_area_entered(area: Area3D) -> void:
	if (!bounce_cooldown):
		spring_touched.emit()
		$CooldownTimer.start()
		$SquashAndStretchTimer.start()
		$BoingSound.play()
		bounce_cooldown = true
		squash_and_stretch = true

func _on_cooldown_timer_timeout() -> void:
	print("[Spring] cooldown done")
	bounce_cooldown = false

func _on_squash_and_stretch_timer_timeout() -> void:
	print("[Spring] squash and stretch done")
	squash_and_stretch = false
