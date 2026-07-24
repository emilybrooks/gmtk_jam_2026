extends Node3D

const HORIZ_TEX_SCROLL_SPEED = 1.0
const VERT_TEX_SCROLL_SPEED = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vert_scaling_factor = clampf(scale.y, 1.0, 7.5)
	$Cylinder.get_surface_override_material(0).uv1_offset.x += delta * HORIZ_TEX_SCROLL_SPEED
	$Cylinder.get_surface_override_material(0).uv1_offset.y += delta * VERT_TEX_SCROLL_SPEED * (5.0 / vert_scaling_factor)
	
	# This ensures the texture perfectly loops
	if ($Cylinder.get_surface_override_material(0).uv1_offset.x > 1):
		$Cylinder.get_surface_override_material(0).uv1_offset.x -= 1
	if ($Cylinder.get_surface_override_material(0).uv1_offset.y > 1):
		$Cylinder.get_surface_override_material(0).uv1_offset.y -= 1
