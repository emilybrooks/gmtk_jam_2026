extends Label

var active: bool = false
var start_time: float
var clear_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		var elapsed_time = get_elapsed_time()
		text = time_to_string(elapsed_time)

func get_elapsed_time() -> float:
	var current_time: float = Time.get_unix_time_from_system()
	var elapsed_time: float = current_time - start_time
	return elapsed_time

func time_to_string(time: float) -> String:
	var minutes: float = floor(time / 60)
	var seconds: float = fmod(time, 60)
	return "%d:%05.2f" % [minutes, seconds]
	
func _on_game_init() -> void:
	clear_time = 0.0
	text = "0:00.00"

func _on_game_start() -> void:
	active = true
	start_time = Time.get_unix_time_from_system()

func _on_victory() -> void:
	active = false
	clear_time = get_elapsed_time()
