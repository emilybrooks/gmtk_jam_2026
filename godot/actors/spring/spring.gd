extends Node3D

var disabled_material = preload("res://actors/spring/spring_disabled_material_3d.tres")

signal spring_touched

@onready var touch_cooldown = false
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
	
	if not %Player.ability_spring.owned:
		$Area3D/SpringModel/spring.set_surface_override_material(0, disabled_material)
		$Area3D/SpringModel/spring/platform.set_surface_override_material(0, disabled_material)
		$Area3D/SpringModel/spring/spring2.set_surface_override_material(0, disabled_material)
	else:
		$Area3D/SpringModel/spring.set_surface_override_material(0, null)
		$Area3D/SpringModel/spring/platform.set_surface_override_material(0, null)
		$Area3D/SpringModel/spring/spring2.set_surface_override_material(0, null)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if (!touch_cooldown):
		if (%Player.ability_spring.owned):
			spring_touched.emit()
			$SquashAndStretchTimer.start()
			$BoingSound.play()
			squash_and_stretch = true
		else:
			$DisabledSound.play()
	$CooldownTimer.start()
	touch_cooldown = true

func _on_cooldown_timer_timeout() -> void:
	print("[Spring] cooldown done")
	touch_cooldown = false

func _on_squash_and_stretch_timer_timeout() -> void:
	print("[Spring] squash and stretch done")
	touch_cooldown = false
