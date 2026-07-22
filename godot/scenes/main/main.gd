# Title Screen
extends Control

func _ready() -> void:
	var version = ProjectSettings.get_setting("application/config/version")
	%LabelVersion.text = "Ver.%s" % version

	# prevent scaling the window smaller than the game's resolution
	var game_resolution: Vector2 = get_viewport_rect().size
	get_window().min_size = game_resolution

	if OS.get_name() == "Web":
		%ButtonQuit.hide()
		%ButtonWindow.hide()
		%ButtonFullscreen.hide()
		
	%ButtonStart.grab_focus()

func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/3d_test/3d_test.tscn")

func _on_button_window_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_button_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_button_quit_pressed() -> void:
	get_tree().quit()
