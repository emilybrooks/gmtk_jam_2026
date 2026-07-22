class_name AnimatedTextureRect extends TextureRect
## A TextureRect that can play sprite animations

## The SpriteFrames resource containing the animation(s). Allows you the option to load, edit, clear, make unique and save the states of the SpriteFrames resource.
@export var sprite_frames: SpriteFrames

## The key of the animation to play when the scene loads.
@export var autoplay: String

var _animation: String = "default"
var _playing: bool = false
var _elapsed: float = 0.0
var _frame_index: int = 0

func _ready() -> void:
	if autoplay != "":
		play(autoplay)
		
func _process(delta: float) -> void:
	if _playing == false:
		return
		
	if sprite_frames == null:
		return
	
	assert(sprite_frames.has_animation(_animation), "Animation %s doesn't exist." % _animation)
	
	var final_frame = sprite_frames.get_frame_count(_animation) - 1
	var animation_fps = sprite_frames.get_animation_speed(_animation)
	
	_elapsed += delta

	## advance as many frames as we can
	while true:
		# each frame can set a different frame duration, so we need to calculate it per frame
		var frame_duration = sprite_frames.get_frame_duration(_animation, _frame_index)
		var frame_duration_seconds = frame_duration / animation_fps
		
		if _elapsed >= frame_duration_seconds:
			# advance the frame
			_frame_index += 1
			_elapsed -= frame_duration_seconds
			
			# if we're at the end of the animation
			if _frame_index > final_frame:
				match sprite_frames.get_animation_loop(_animation):
					true:
						# loop
						_frame_index = 0
					false:
						# end the animation
						_frame_index = final_frame
						_playing = false
				
		else:
			break
			
	texture = sprite_frames.get_frame_texture(_animation, _frame_index)

func play(animation_name: StringName) -> void:
	_animation = name
	_playing = true
	_elapsed = 0.0
	_frame_index = 0
