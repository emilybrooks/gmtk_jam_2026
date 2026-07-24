extends Node3D

var state: State
@onready var player := owner

func change_state(new_state: State) -> void:
	if state:
		state.exit()
	state = new_state
	state.enter()

func _ready() -> void:
	%LeftShoe.position = %LeftStand.position
	%LeftShoe.rotation = %LeftStand.rotation
	%RightShoe.position = %RightStand.position
	%RightShoe.rotation = %RightStand.rotation
	
	change_state($StateFeetStand)
	
func walk() -> void:
	if state != $StateFeetWalk:
		change_state($StateFeetWalk)
	
func air() -> void:
	if state != $StateFeetAir:
		change_state($StateFeetAir)
	
func stand() -> void:
	if state != $StateFeetStand:
		change_state($StateFeetStand)

func _process(delta: float) -> void:
	var new_state = state.update(delta)
	if new_state:
		change_state(new_state)
