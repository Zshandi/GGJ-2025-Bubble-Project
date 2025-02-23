extends Area2D

@export_file("*.tscn")
var load_scene_path:String = ""

@export
var wobble_push_on_mouse := false
@export
var wobble_push_divisor := 1200


var mouse_velocity := Vector2.ZERO
var mouse_over := false
var mouse_was_over := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && mouse_over:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			$BubbleCollision.pop()
			await $BubbleCollision.pop_finished
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_packed(load(load_scene_path))
			MusicPlayer.play()
	
	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		mouse_velocity = mouse_event.velocity
		
		if wobble_push_on_mouse and mouse_over != mouse_was_over:
			mouse_was_over = mouse_over
			var speed = mouse_velocity.length()
			if not mouse_over: speed = -speed
			print_debug("Mouse over button, speed: ", speed)
			$BubbleCollision.add_wobble_push(mouse_velocity, speed / wobble_push_divisor)
			


func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
