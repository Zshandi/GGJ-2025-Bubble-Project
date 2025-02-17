extends Area2D
class_name BubbleCollectible

signal collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BubbleCollision.color.h = randf()
	%BubbleCollision.start_wobble()

func _on_body_entered(body: Node2D) -> void:
	if body is BubbleCharacter:
		var character = body as BubbleCharacter
		
		var current_scale = %BubbleCollision.global_scale.x
		var current_size = %BubbleCollision.shape.radius * current_scale
		
		character.collect_bubble(current_size)
		collected.emit()
		queue_free()

func get_size() -> float:
	var current_scale = %BubbleCollision.global_scale.x
	return %BubbleCollision.shape.radius * current_scale
