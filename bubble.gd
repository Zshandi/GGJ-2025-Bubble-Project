extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var direction = get_global_mouse_position() - global_position
		direction = direction.normalized()
		
		apply_central_impulse(direction * 200)
