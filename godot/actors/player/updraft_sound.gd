extends AudioStreamPlayer3D

# The sound is a little loud by default
const REGULAR_VOLUME_DB = -2.0

# The minimum value allowed in the editor
const SILENCE_DB = -80.0

const EPSILON = 0.01

var rng = RandomNumberGenerator.new()
var fade_in_tween = null
var fade_out_tween = null

func play_wind_sfx():
	if self.playing and self.volume_db >= (REGULAR_VOLUME_DB - EPSILON):
		# We're playing the SFX at full volume, don't do anything
		return
	elif not self.playing:
		# We're not playing any SFX. Pick a random point in the SFX to start at
		var starting_point = rng.randf_range(0.0, self.stream.get_length())
		self.play(starting_point)
	elif fade_out_tween != null:
		# We ARE currently playing a sound effect, but it's not at full volume.
		# This might be because of the fade-out tween, so kill it and just turn
		# the volume up on the current SFX.
		fade_out_tween.kill()
	
	fade_in_tween = create_tween()
	fade_in_tween.tween_property(self, "volume_db", REGULAR_VOLUME_DB, 0.2)
	
func stop_wind_sfx():
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "volume_db", SILENCE_DB, 2.0)
	fade_out_tween.connect("finished", on_fade_out_tween_finished)
	
func on_fade_out_tween_finished():
	self.stop()
