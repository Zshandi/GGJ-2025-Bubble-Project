@tool
extends CollisionShape2D

signal pop_finished

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%BubbleColor.modulate = value

@export
var base_scale := 1.0:
	set(value):
		base_scale = value
		scale = Vector2(value, value)
	get: return base_scale

@export
var wobble_on_ready := false

var current_wobbles:Array[Wobble] = []

func start_wobble():
	%AnimationPlayer.play("wobble")

func pop(play_sound:bool = true):
	%AnimationPlayer.play("pop")
	if play_sound:
		%AudioPlayer_Pop.play()

func reset():
	%AnimationPlayer.play("RESET")

func _ready() -> void:
	%BubbleColor.modulate = color
	if Engine.is_editor_hint(): return
	if wobble_on_ready:
		start_wobble()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	var trans = Transform2D.IDENTITY.scaled(Vector2(base_scale, base_scale))
	if current_wobbles.size() > 0:
		for wobble in current_wobbles:
			wobble._process(delta)
			trans = add_stretch(trans, wobble.current_stretch, wobble.direction)
		
		transform = trans
	elif not %AnimationPlayer.is_playing():
		transform = trans

# Internal for calculations
func add_stretch(to:Transform2D, scale_distance:float, direction:Vector2) -> Transform2D:
	
	var rotation = direction.angle_to(Vector2.UP)
	to = to.rotated(rotation)
	
	var scale := Vector2(1.0 - scale_distance, 1.0 + scale_distance)
	to = to.scaled(scale)
	
	to = to.rotated(-rotation)
	return to

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	if anim_name == &"pop":
		pop_finished.emit()

func add_wobble(starting_speed:float, spring_constant:float, attenuation:float, direction:Vector2):
	var wobble := Wobble.new()
	wobble.current_speed = starting_speed
	wobble.spring_constant = spring_constant
	wobble.attenuation = attenuation
	wobble.direction = direction
	current_wobbles.append(wobble)

func get_spring_constant_for_period(period:float):
	# period = 2*PI * sqrt(1/spring_constant)
	# (period / (2*PI))^2 = 1/spring_constant
	# spring_constant = 1/(period / (2*PI))^2
	return 1.0 / pow(period / (2*PI), 2)

func get_speed_for_distance(dist:float, spring_const:float):
	# (1/2)mv^2 = (1/2)kx^2 (from Google)
	# v = sqrt(kx^2/m), but m is 1, so
	# v = sqrt(kx^2)
	return sqrt(spring_const * dist * dist)

class Wobble:
	var current_stretch := 0.0
	var current_speed := 0.0
	
	var spring_constant := 1.0
	var max_stretch := 0.5
	var attenuation := 0.9
	var direction := Vector2.UP
	
	func _process(delta:float) -> void:
		current_stretch += current_speed * delta
		
		if (current_stretch > max_stretch or current_stretch < -max_stretch):
			print_debug("max_stretch reached: ", current_stretch, current_speed)
			current_stretch = clampf(current_stretch, -max_stretch, max_stretch)
			current_speed = 0
		
		current_speed -= current_stretch * spring_constant * delta
		current_speed *= attenuation
	
	func get_rate_seconds() -> float:
		return 2*PI * sqrt(1/spring_constant)
	
	
