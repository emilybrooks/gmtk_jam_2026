extends Label

func _ready() -> void:
	%Timer.start()
	
func _process(delta: float) -> void:
	#var minutes = (%Timer.time_left / 60)
	#var seconds = int(%Timer.time_left) % 60
	#text = "%02d:%02d" % [minutes, seconds]
	var time_left: float = %Timer.time_left + 1
	text = "%d seconds until you lose your ability..." % time_left


func _on_clock_item_clock_item_collected() -> void:
	var currenttime = %Timer.get_time_left()
	%Timer.set_wait_time(currenttime + 10)
	%Timer.start()
