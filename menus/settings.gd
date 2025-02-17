@tool
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

@export
# This is an editor-only value used to conveniently clear the data for testing
var clear_settings:bool:
	get: return false
	set(value):
		print_debug("Deleting settings file...")
		DirAccess.remove_absolute("user://settings")

enum AntiAliasingSetting
{
	NONE, # No anti-aliasing
	LOW,  # 2x MSAA & Screen Space AA
	MEDIUM, # 4x MSAA, Screen Space AA, and TAA
	HIGH # 8x MSAA, Screen Space AA, and TAA
}

var anti_aliasing := AntiAliasingSetting.NONE:
	get:
		return anti_aliasing
	set(value):
		anti_aliasing = value
		match value:
			AntiAliasingSetting.NONE:
				get_viewport().use_taa = false
				get_viewport().msaa_2d = Viewport.MSAA_DISABLED
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			AntiAliasingSetting.LOW:
				get_viewport().use_taa = false
				get_viewport().msaa_2d = Viewport.MSAA_2X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			AntiAliasingSetting.MEDIUM:
				get_viewport().use_taa = true
				get_viewport().msaa_2d = Viewport.MSAA_4X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			AntiAliasingSetting.HIGH:
				get_viewport().use_taa = true
				get_viewport().msaa_2d = Viewport.MSAA_8X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if OS.has_feature("pc"):
		# Default to Medium anti-aliasing on Desktop
		anti_aliasing = AntiAliasingSetting.MEDIUM
	elif OS.has_feature("web"):
		# compatibility renderer used for web does not yet support anti-aliasing
		%AntiAliasing.hide()
	
	load_settings()
	update_full_screen_text()
	%MusicVolumeSlider.set_value_no_signal(music_volume)
	%SoundVolumeSlider.set_value_no_signal(sound_volume)
	%AntiAliasingButton.select(anti_aliasing as int)

func update_full_screen_text():
	if is_full_screen:
		$FullscreenToggle.text = "Full Screen: Enabled"
	else:
		$FullscreenToggle.text = "Full Screen: Disabled"

func _on_fullscreen_toggle_pressed() -> void:
	is_full_screen = !is_full_screen
	update_full_screen_text()
	save_settings()

func _on_music_volume_slider_value_changed(value: float) -> void:
	music_volume = value
	save_settings()

func _on_sound_volume_slider_value_changed(value: float) -> void:
	sound_volume = value
	save_settings()

func _on_anti_aliasing_button_item_selected(index: int) -> void:
	anti_aliasing = index as AntiAliasingSetting
	save_settings()

func _on_back_pressed() -> void:
	back_button_pressed.emit()


func save_settings() -> void:
	var save_dict := {}
	save_dict["music_volume"] = music_volume
	save_dict["sound_volume"] = sound_volume
	save_dict["is_full_screen"] = is_full_screen
	save_dict["anti_aliasing"] = anti_aliasing
	
	var save_file := FileAccess.open("user://settings", FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func load_settings() -> void:
	if !FileAccess.file_exists("user://settings"):
		# If no settings have been changed, leave values as default
		return
	
	var save_file := FileAccess.open("user://settings", FileAccess.READ)
	var save_dict:Dictionary = save_file.get_var()
	
	music_volume = save_dict["music_volume"]
	sound_volume = save_dict["sound_volume"]
	is_full_screen = save_dict["is_full_screen"]
	if save_dict.has("anti_aliasing"):
		anti_aliasing = save_dict["anti_aliasing"]
