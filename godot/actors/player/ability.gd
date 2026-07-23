class_name Ability

var name: String = "ability name"
var owned: bool = true
var icon

func _init(_name: String, _icon) -> void:
	name = _name
	icon = _icon

func enable() -> void:
	owned = true
	icon.visible = true

func disable() -> void:
	owned = false
	icon.visible = false
	
