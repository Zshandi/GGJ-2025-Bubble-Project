extends Node2D

@export
var reset := false

@export
var add_wobble := false

@export
var starting_speed := 1.0

@export
var spring_constant := 1.0

@export
var attenuation := 0.9

@export
var stretch_direction := Vector2.UP

func _process(delta: float) -> void:
	if add_wobble:
		%Bubble.add_wobble(starting_speed, spring_constant, attenuation, stretch_direction)
		add_wobble = false
	elif reset:
		%Bubble.current_wobbles.clear()
		reset = false
