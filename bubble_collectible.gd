extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BubbleColor.modulate.h = randf()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is BubbleCharacter:
		var character = body as BubbleCharacter
		
		var current_scale = %BubbleCollision.global_scale.x
		var current_size = %BubbleCollision.shape.radius * current_scale
		
		character.collect_bubble(current_size)
		queue_free()
