class_name Raycast3DHelper
## Helper class for using a raycast

## Where the raycast collided. If it didn't collide with anything, this will be identical to [param end].
var endpos: Vector3

## How much of the total distance the raycast traveled, from 0.0 to 1.0. If the raycast didn't collide, this will be 1.0
var fraction: float

## The normal of the surface the raycast collided with.
var normal: Vector3

## Perform a raycast from [param start] to [param end].
## You can optionally specify objects to exclude from colliding with this raycast, see [member PhysicsRayQueryParameters3D.exclude].
func _init
(
	start: Vector3,
	end: Vector3,
	space_state: PhysicsDirectSpaceState3D,
	exclude: Array[RID] = []
):
	var query := PhysicsRayQueryParameters3D.new()
	query.from = start
	query.to = end
	if exclude:
		query.exclude = exclude
	
	var result: Dictionary = space_state.intersect_ray(query)
	if !result.is_empty():
		endpos = result.position
		normal = result.normal
		fraction = start.distance_to(endpos) / start.distance_to(end)
	else:
		# Didn't hit anything
		endpos = end
		fraction = 1.0
