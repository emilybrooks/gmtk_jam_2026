extends Node3D

const REVOLUTIONS_PER_SECOND = 0.5
const BOBS_PER_SECOND = 1.0
const BOB_SPEED = 0.4

signal clock_item_collected

@onready var elapsed_time = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	if (elapsed_time >= 10.0):
		elapsed_time = 0.0
	
	# The clock model is kind of weird and isn't centered, so if you rotate it,
	# it doesn't look right. Just rotate the entire scene.
	self.rotation.y += deg_to_rad(360 * REVOLUTIONS_PER_SECOND * delta)
	
	$ClockModel.position.y += BOB_SPEED * delta * sin(deg_to_rad(360 * BOBS_PER_SECOND * elapsed_time))

func _on_area_3d_area_entered(area: Area3D) -> void:
	clock_item_collected.emit()
	$CollectSound.play()
	disable()

func enable() -> void:
	visible = true
	%Area3D.set_collision_mask_value(2, true)
	
func disable() -> void:
	visible = false
	%Area3D.set_collision_mask_value(2, false)
