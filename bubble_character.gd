@tool
extends RigidBody2D
class_name BubbleCharacter

@export
var color_weight := 0.5

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%Bubble.color = value

@export
var bubble_speed := 100.0

@onready
var starting_scale:float = %Bubble.base_scale

signal started
signal died

var is_dead := false
var is_starting := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Bubble.color = color
	
	if Engine.is_editor_hint(): return
	freeze = true
	is_starting = true
	
	print_debug("Starting scale: ", %Bubble.global_scale)
	print_debug("Starting hue: ", %Bubble.color.h)
	
	assert(is_equal_approx(0.5, size_to_area(area_to_size(0.5))))
	assert(is_equal_approx(0.5, area_to_size(size_to_area(0.5))))
	assert(is_equal_approx(1, size_to_area(area_to_size(1))))
	assert(is_equal_approx(1, area_to_size(size_to_area(1))))
	assert(is_equal_approx(3, size_to_area(area_to_size(3))))
	assert(is_equal_approx(3, area_to_size(size_to_area(3))))

func get_normalized_direction() -> Vector2:
	var direction = -(get_global_mouse_position() - global_position)
	return direction.normalized()

var move_pressed := false
var move_just_pressed = false

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed("move"):
		if !move_pressed:
			move_just_pressed = true
		move_pressed = true
	else:
		move_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if move_just_pressed:
		move_just_pressed = false
		
		if is_starting:
			freeze = false
			is_starting = false
			started.emit()
		
		var direction = get_normalized_direction()
		
		apply_central_impulse(direction * bubble_speed)
		play_sound(%AudioPlayer_Move)
		
		add_wobble(direction)
	
	if get_colliding_bodies().size() > 0:
		die()
	
	# Debug
	if OS.is_debug_build():
		if Input.is_action_just_pressed("spawn_bubble"):
			# Spawn a new bubble at cursor
			var bubble = preload("res://levels/objects/bubble_collectible.tscn").instantiate()
			get_tree().root.add_child(bubble)
			bubble.owner = get_tree().root
			bubble.global_position = get_global_mouse_position()
			play_sound(%AudioPlayer_Move)
		
		if Input.is_action_just_pressed("reset_size"):
			%Bubble.base_scale = starting_scale

func add_wobble(direction:Vector2) -> void:
	%Bubble.add_wobble_push(direction, 1.0 / (%Bubble.base_scale / starting_scale))

func die():
	is_dead = true
	died.emit()
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	%Bubble.process_mode = PROCESS_MODE_ALWAYS
	%Bubble.pop()
	await %Bubble.pop_finished
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

static func size_to_area(radius:float) -> float:
	return PI*pow(radius, 2)

static func area_to_size(area:float) -> float:
	return pow(area/PI, 1.0/2)

func collect_bubble(size: float, bubble:BubbleCollectible):
	var current_size = get_radius()
	
	var current_area = size_to_area(current_size)
	var added_area = size_to_area(size)
	var new_area = current_area + added_area
	var new_size = area_to_size(new_area)
	
	print_debug("new_size: ", new_size, ", current_size: ", current_size)
	
	%Bubble.base_scale *= new_size / current_size
	print_debug("New scale: ", %Bubble.global_scale)
	
	if bubble.should_mix_color:
		# Average the color with the new one
		color = lerp(color, bubble.color, color_weight)
		# Restore some saturation and value if they were lost in the lerp
		color.v = lerp(color.v, bubble.color.v, color_weight)
		color.s = lerp(color.s, bubble.color.s, color_weight)
	else:
		color = bubble.color
	print_debug("New color: ", color)
	print_debug("New HSV: (", color.h*360, ", ", color.s*100, ", ", color.v*100, ")")
	
	play_sound(%AudioPlayer_Collect)

func get_radius() -> float:
	return %Bubble.shape.radius * %Bubble.base_scale

func play_sound(base_player:AudioStreamPlayer):
	# Allow many sounds at the same time
	var player := base_player.duplicate() as AudioStreamPlayer
	add_child(player)
	player.pitch_scale *= randf_range(0.8, 1.2)
	player.play()
	await player.finished
	player.queue_free()
