@tool
extends Area2D
class_name BubbleCollectible

signal collected

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%BubbleCollision.color = value

@export
var randomize_color := true

@export
var animate_hue := false

@export_range(0.0, 1.0, 0.001)
var hue_shift_per_second := 0.1

var wobble_time := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if get_tree().current_scene == self:
		position = Vector2(500, 500)
	
	if animate_hue:
		color.h += hue_shift_per_second * delta
		%BubbleCollision.color = color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BubbleCollision.color = color
	if Engine.is_editor_hint(): return
	if randomize_color:
		color.h = randf()
		%BubbleCollision.color = color
	

func _on_body_entered(body: Node2D) -> void:
	if body is BubbleCharacter:
		var character = body as BubbleCharacter
		
		var current_scale = %BubbleCollision.base_scale * global_scale.x
		var current_size = %BubbleCollision.shape.radius * current_scale
		
		character.collect_bubble(current_size, self)
		collected.emit()
		queue_free()

func get_size() -> float:
	var current_scale = %BubbleCollision.global_scale.x
	return %BubbleCollision.shape.radius * current_scale
