extends Label

func _ready() -> void:
	%Timer.start()
	
func _process(delta: float) -> void:
	var minutes = (%Timer.time_left / 60)
	var seconds = int(%Timer.time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]
