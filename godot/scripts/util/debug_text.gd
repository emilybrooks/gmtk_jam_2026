extends Label

var new_text: String = ""

func _process(delta: float) -> void:
	text = new_text
	new_text = ""

func print(input: String) -> void:
	new_text += input + "\n"
