extends RigidBody2D
class_name BubbleCharacter

# Normally this would be 2
@export
var area_pow := 2.0

@export
var hue_scale := 1.0/345.67

@export
var bubble_speed := 100.0

@onready
var starting_scale:Vector2 = %BubbleCollision.scale

signal started
signal died

var is_dead := false
var is_starting := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	is_starting = true
	
	print_debug("Starting scale: ", %BubbleCollision.global_scale)
	print_debug("Starting hue: ", %BubbleColor.modulate.h)
	
	assert(is_equal_approx(0.5, size_to_area(area_to_size(0.5))))
	assert(is_equal_approx(0.5, area_to_size(size_to_area(0.5))))
	assert(is_equal_approx(1, size_to_area(area_to_size(1))))
	assert(is_equal_approx(1, area_to_size(size_to_area(1))))
	assert(is_equal_approx(3, size_to_area(area_to_size(3))))
	assert(is_equal_approx(3, area_to_size(size_to_area(3))))

func get_normalized_direction() -> Vector2:
	var direction = -(get_global_mouse_position() - global_position)
	return direction.normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move"):
		if is_starting:
			$AnimationPlayer.play("wobble")
			freeze = false
			is_starting = false
			started.emit()
		
		var direction = get_normalized_direction()
		
		apply_central_impulse(direction * bubble_speed)
		play_sound(%AudioPlayer_Move)
	
	if get_colliding_bodies().size() > 0:
		die()
	
	# Debug
	if OS.is_debug_build():
		if Input.is_action_just_pressed("spawn_bubble"):
			# Spawn a new bubble at cursor
			var bubble = preload("res://bubble_collectible.tscn").instantiate()
			get_tree().root.add_child(bubble)
			bubble.owner = get_tree().root
			bubble.global_position = get_global_mouse_position()
			play_sound(%AudioPlayer_Move)
		
		if Input.is_action_just_pressed("reset_size"):
			%BubbleCollision.scale = starting_scale


func die():
	is_dead = true
	died.emit()
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.process_mode = PROCESS_MODE_ALWAYS
	$AnimationPlayer.play("pop")
	%AudioPlayer_Pop.play()
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

func size_to_area(radius:float) -> float:
	return PI*pow(radius, area_pow)

func area_to_size(area:float) -> float:
	return pow(area/PI, 1.0/area_pow)

func collect_bubble(size: float):
	var current_scale = %BubbleCollision.global_scale.x
	var current_size = %BubbleCollision.shape.radius * current_scale
	
	var current_area = size_to_area(current_size)
	var added_area = size_to_area(size)
	var new_area = current_area + added_area
	var new_size = area_to_size(new_area)
	
	print_debug("new_size: ", new_size, ", current_size: ", current_size)
	
	%BubbleCollision.global_scale *= new_size / current_size
	print_debug("New scale: ", %BubbleCollision.global_scale)
	
	# Change the color as we grow
	#%BubbleColor.modulate.h = fmod(%BubbleColor.modulate.h + size * hue_scale, 1.0)
	print_debug("New hue: ", %BubbleColor.modulate.h)
	
	play_sound(%AudioPlayer_Collect)

func play_sound(base_player:AudioStreamPlayer):
	# Allow many sounds at the same time
	var player := base_player.duplicate() as AudioStreamPlayer
	add_child(player)
	player.pitch_scale *= randf_range(0.8, 1.2)
	player.play()
	await player.finished
	player.queue_free()
