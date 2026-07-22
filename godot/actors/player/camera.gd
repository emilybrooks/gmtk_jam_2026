extends Camera3D

@onready var player: Node3D = owner

## Where the camera will point to, typically around the player's head
var look_at_offset := Vector3(0.0, 1.45, 0.0)
var invert_horizontal: bool = true
var spherical_coords := SphericalCoords.new()
var camera_invert: bool = true

## radians per frame
const HORIZONTAL_ORBIT_SPEED: float = deg_to_rad(3)

func _ready() -> void:
	spherical_coords.radius = 3.0
	spherical_coords.altitude = deg_to_rad(12)
	position = spherical_coords.to_cartesian(look_at_offset)
			
func _process(delta: float) -> void:
	var camera_horizontal: float = Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
	if camera_invert:
		camera_horizontal *= -1
		
	spherical_coords.azimuth += HORIZONTAL_ORBIT_SPEED * camera_horizontal
	
	position = spherical_coords.to_cartesian(look_at_offset)
	look_at(player.position + look_at_offset)
