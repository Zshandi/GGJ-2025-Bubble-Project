extends Area2D

@export_file("*.tscn")
var load_scene_path:String = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && mouse_over:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			$BubbleCollision.pop()
			await $BubbleCollision.pop_finished
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_packed(load(load_scene_path))
			MusicPlayer.play()

var mouse_over := false

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
