extends Node3D

signal player_in_updraft

@export var updraft_height = 4

func _ready() -> void:
	$Area3D/CollisionShape3D.shape.height = updraft_height
	# I'm sure I just set this up wrong, so this is my fault.
	# But I need to do this in order to get the updraft collision in the right place.
	$Area3D/CollisionShape3D.position.y = (updraft_height - 2) / 2.0

func _process(delta: float) -> void:
	if $Area3D.has_overlapping_areas():
		player_in_updraft.emit()
