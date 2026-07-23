class_name Ability

var name: String = "ability name"
var owned: bool = false
var icon

func _init(_name: String, _owned: bool, _icon) -> void:
	name = _name
	owned = _owned
	icon = _icon
