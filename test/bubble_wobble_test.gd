extends Node2D

@export
var reset := false

@export
var add_wobble := false

@export
var start_wobble_rotation := false

@export
var starting_speed := 1.0

@export
var spring_constant := 1.0

@export
var attenuation := 0.9

@export
var stretch_direction := Vector2.UP

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move"):
		var direction = (global_position - get_viewport().get_mouse_position()).normalized()
		%Bubble.add_wobble(starting_speed, spring_constant, attenuation, direction)
	if add_wobble:
		%Bubble.add_wobble(starting_speed, spring_constant, attenuation, stretch_direction)
		add_wobble = false
	elif start_wobble_rotation:
		start_wobble_rotation = false
		%Bubble.add_wobble(starting_speed, spring_constant, attenuation, Vector2.UP)
		var period = %Bubble.current_wobbles[0].get_rate_seconds()
		await get_tree().create_timer(period/4).timeout
		%Bubble.add_wobble(starting_speed, spring_constant, attenuation, Vector2.UP + Vector2.RIGHT)
	elif reset:
		%Bubble.current_wobbles.clear()
		reset = false
