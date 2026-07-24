extends Camera3D

@onready var player: Node3D = owner

## Where the camera will point to, typically around the player's head
var look_at_offset := Vector3(0.0, 1.45, 0.0)
var spherical_coords := SphericalCoords.new()
var horiz_camera_invert: bool = true
var vert_camera_invert: bool = true

## radians per frame
const HORIZONTAL_ORBIT_SPEED: float = deg_to_rad(3)
const VERTICAL_ORBIT_SPEED: float = deg_to_rad(2)

const ALTITUDE_MIN = -0.5
const ALTITUDE_MAX = PI / 2 - 0.1

func _ready() -> void:
	spherical_coords.radius = 3.0
	spherical_coords.altitude = deg_to_rad(12)
	position = spherical_coords.to_cartesian(look_at_offset)
			
func _process(delta: float) -> void:
	var camera_horizontal: float = Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
	if horiz_camera_invert:
		camera_horizontal *= -1
		
	spherical_coords.azimuth += HORIZONTAL_ORBIT_SPEED * camera_horizontal
	
	var camera_vertical: float = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
	if vert_camera_invert:
		camera_vertical *= 1
		
	spherical_coords.altitude += VERTICAL_ORBIT_SPEED * camera_vertical
	spherical_coords.altitude = clampf(spherical_coords.altitude, ALTITUDE_MIN, ALTITUDE_MAX)
	
	position = spherical_coords.to_cartesian(look_at_offset)
	look_at(player.position + look_at_offset)
