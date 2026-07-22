class_name SphericalCoords

var radius: float
var azimuth: float
var altitude: float

func _init(_radius: float = 0.0, _azimuth: float = 0.0, _altitude: float = 0.0):
	self.radius = _radius
	self.azimuth = _azimuth
	self.altitude = _altitude

func to_cartesian(origin: Vector3) -> Vector3:
	var xz_distance: float = radius * cos(altitude)
	var y_distance: float = radius * sin(altitude)
	var output: Vector3
	output.x = origin.x + xz_distance * sin(azimuth)
	output.y = origin.y + y_distance
	output.z = origin.z + xz_distance * cos(azimuth)
	return output
