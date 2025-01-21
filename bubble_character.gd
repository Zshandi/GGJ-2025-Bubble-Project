extends RigidBody2D
class_name BubbleCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var direction = get_global_mouse_position() - global_position
		direction = direction.normalized()
		
		apply_central_impulse(direction * 200)

func collect_bubble(size: float):
	var current_scale = $BubbleCollision.scale.x
	
	var current_size = $BubbleCollision.shape.radius * current_scale
	
	#var current_volume = PI*pow(current_size, 3)*4.0/3.0
	#var added_volume = PI*pow(size, 3)*4.0/3.0
	#var new_volume = current_volume + added_volume
	#
	#var new_size = pow(new_volume, 1.0/3.0)/PI/(4.0/3.0)
	
	var current_volume = PI*pow(current_size, 2)
	var added_volume = PI*pow(size, 2)
	var new_volume = current_volume + added_volume
	
	var new_size = pow(new_volume, 1.0/2.0)/PI
	
	$BubbleCollision.scale *= new_size / current_size
