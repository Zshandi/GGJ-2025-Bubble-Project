@tool
extends CollisionShape2D

signal pop_finished

@export
var color := Color.WHITE:
	get: return color
	set(value):
		color = value
		if is_node_ready():
			%BubbleColor.modulate = value

@export
var wobble_on_ready := false

func start_wobble():
	%AnimationPlayer.play("wobble")

func pop(play_sound:bool = true):
	%AnimationPlayer.play("pop")
	if play_sound:
		%AudioPlayer_Pop.play()

func reset():
	%AnimationPlayer.play("RESET")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	%BubbleColor.modulate = color
	if wobble_on_ready:
		start_wobble()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	if anim_name == &"pop":
		pop_finished.emit()
