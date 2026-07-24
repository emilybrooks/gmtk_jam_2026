extends Node3D

signal player_entered_updraft
signal player_exited_updraft

@export var updraft_height = 4

@onready var player_is_in_updraft = false

const REVOLUTIONS_PER_SECOND = 1.5

func _ready() -> void:
	$Area3D/CollisionShape3D.shape.height = updraft_height
	$WindCylinder.scale.y = updraft_height
	# I'm sure I just set this up wrong, so this is my fault.
	# But I need to do this in order to get the updraft collision in the right place.
	$Area3D/CollisionShape3D.position.y = (updraft_height - 2) / 2.0

func _process(delta: float) -> void:
	if $Area3D.has_overlapping_areas():
		player_entered_updraft.emit()
		player_is_in_updraft = true
	elif player_is_in_updraft:
		player_exited_updraft.emit()
		player_is_in_updraft = false
	
	$Area3D/FanModel.rotation.y += deg_to_rad(360 * REVOLUTIONS_PER_SECOND * delta)
