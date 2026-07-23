extends Node3D

@onready var label_3d_jump: Label3D = %Label3DJump
@onready var label_3d_float: Label3D = %Label3DFloat

var elapsed_time: float = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	%Sprite3DStar.position.y = 1.0 + sin(elapsed_time * 2) * 0.1
	
	%PivotJump.rotate_y(deg_to_rad(90) * delta)
	%PivotJump.rotate_x(deg_to_rad(45) * delta)
	%PivotFloat.rotate_y(deg_to_rad(120) * delta)
