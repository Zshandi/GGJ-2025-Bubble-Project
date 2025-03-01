extends Area2D

@export_file("*.tscn")
var load_scene_path:String = ""

@export
var wobble_push_on_mouse := false
@export
var wobble_push_divisor := 1200
@export
var opposing_push_timeout_seconds := 1.0

var mouse_velocity := Vector2.ZERO
var mouse_over := false
var mouse_was_over := false

var last_push_mouse_velocity := Vector2.ZERO
var last_opposing_push_timeout := 0.0
var all_push_timeout := 0.0

func _process(delta: float) -> void:
	if last_opposing_push_timeout > 0:
		last_opposing_push_timeout -= delta
	if all_push_timeout > 0:
		all_push_timeout -= delta
		

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
			
			# Limit pushing in the opposite direction
			if all_push_timeout > 0:
				print_debug("#!!! CALM DOWN !!!#")
				return
			if last_push_mouse_velocity != Vector2.ZERO:
				print_debug("last_push_mouse_velocity: ", last_push_mouse_velocity)
				var direction_change := absf(mouse_velocity.angle_to(last_push_mouse_velocity))
				# Update before bailing out
				print_debug("direction_change: ", direction_change)
				if direction_change >= PI/2: # Quarter turn is opposing
					print_debug("last_opposing_push_timeout: ", last_opposing_push_timeout)
					if last_opposing_push_timeout > 0:
						print_debug("!!! ABORTING PUSH !!!")
						last_push_mouse_velocity = Vector2.ZERO
						last_opposing_push_timeout = opposing_push_timeout_seconds
						all_push_timeout = opposing_push_timeout_seconds
						# Hasn't been long enough so bail out
						return
			last_push_mouse_velocity = mouse_velocity
			# Always reset timeout when there's a push
			last_opposing_push_timeout = opposing_push_timeout_seconds
			
			var speed = mouse_velocity.length()
			if not mouse_over: speed = -speed
			$BubbleCollision.add_wobble_push(mouse_velocity, speed / wobble_push_divisor)
			


func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
