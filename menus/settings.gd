extends VBoxContainer

signal back_button_pressed

var music_volume:float:
	get:
		var index = AudioServer.get_bus_index(&"Music")
		return db_to_linear(AudioServer.get_bus_volume_db(index))
	set(value):
		var index = AudioServer.get_bus_index(&"Music")
		AudioServer.set_bus_volume_db(index, linear_to_db(value))

var sound_volume:float:
	get:
		var index = AudioServer.get_bus_index(&"Master")
		return db_to_linear(AudioServer.get_bus_volume_db(index))
	set(value):
		var index = AudioServer.get_bus_index(&"Master")
		AudioServer.set_bus_volume_db(index, linear_to_db(value))

var is_full_screen:bool:
	get:
		return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	set(value):
		if (value): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void:
	update_full_screen_text()
	%MusicVolumeSlider.set_value_no_signal(music_volume)
	%SoundVolumeSlider.set_value_no_signal(sound_volume)

func update_full_screen_text():
	if is_full_screen:
		$FullscreenToggle.text = "Full Screen: Enabled"
	else:
		$FullscreenToggle.text = "Full Screen: Disabled"

func _on_fullscreen_toggle_pressed() -> void:
	is_full_screen = !is_full_screen
	update_full_screen_text()

func _on_music_volume_slider_value_changed(value: float) -> void:
	music_volume = value

func _on_sound_volume_slider_value_changed(value: float) -> void:
	sound_volume = value

func _on_back_pressed() -> void:
	back_button_pressed.emit()
