extends Label

## Seconds.
var initial_clock_duration: float = 99.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	#var minutes = (%Timer.time_left / 60)
	#var seconds = int(%Timer.time_left) % 60
	#text = "%02d:%02d" % [minutes, seconds]
	var time_left: float = %Timer.time_left + 1
	text = "%d seconds until you lose your ability..." % time_left

func _on_clock_item_clock_item_collected() -> void:
	if %Player.current_ability_count() <= 0:
		return
	
	var new_clock_duration: float = %Timer.get_time_left() + 10.0
	%Timer.start(new_clock_duration)

func _on_game_start() -> void:
	%Timer.start(initial_clock_duration)

func _on_timer_timeout() -> void:
	if %Player.current_ability_count() > 0:
		%Timer.start(initial_clock_duration)

func _on_victory() -> void:
	%Timer.stop()
