extends VBoxContainer

signal back_button_pressed

func _ready() -> void:
	update_full_screen()
	var music_index = AudioServer.get_bus_index(&"Music")
	var music_volume = AudioServer.get_bus_volume_db(music_index)
	%MusicVolumeSlider.set_value_no_signal(db_to_linear(music_volume))
	var sound_index = AudioServer.get_bus_index(&"Master")
	var sound_volume = AudioServer.get_bus_volume_db(sound_index)
	%SoundVolumeSlider.set_value_no_signal(db_to_linear(sound_volume))

func update_full_screen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$FullscreenToggle.text = "Full Screen: Enabled"
	else:
		$FullscreenToggle.text = "Full Screen: Disabled"

func _on_fullscreen_toggle_pressed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_full_screen()

func _on_back_pressed() -> void:
	back_button_pressed.emit()


func _on_music_volume_slider_value_changed(value: float) -> void:
	var music_index = AudioServer.get_bus_index(&"Music")
	AudioServer.set_bus_volume_db(
		music_index,
		linear_to_db(value)
	)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	var sound_index = AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_volume_db(
		sound_index,
		linear_to_db(value)
	)
