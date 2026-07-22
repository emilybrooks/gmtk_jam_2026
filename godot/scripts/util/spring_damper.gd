class_name SpringDamper
## A critically damped spring[br]
## Based on code from [url]https://theorangeduck.com/page/spring-roll-call[/url]

## Calculate a critically damped spring for one dimension.[br]
## [param from]: The current value[br]
## [param to]: The goal value[br]
## [param velocity]: The spring's current velocity. This needs to be stored outside of this function[br]
## [param half_life]: The time it takes for the distance to the goal to reduce by half, in seconds.[br]
## Returns a dictionary with keys [param position] and [param velocity].
## Store velocity outside of this function to use as the input for the next update cycle
func calculate(from: float, to: float, velocity: float, half_life: float, delta_time: float) -> Dictionary:
	# y is the time it takes to decay
	var y: float = _halflife_to_damping(half_life) / 2.0
	
	# j is the amplitude of the spring
	var j0:float = from - to
	var j1:float = velocity + j0 * y
	
	var eydt: float = _fast_negexp(y * delta_time)
	
	var out_position: float = eydt * (j0 + j1 * delta_time) + to
	var out_velocity: float = eydt * (velocity - j1 * y * delta_time)
	return {"position": out_position, "velocity": out_velocity}
	
func _halflife_to_damping(damping: float) -> float:
	const EPSILON: float = 0.0001
	return (4.0 * 0.69314718056) / (damping + EPSILON)

func _fast_negexp(x: float) -> float:
	return 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
