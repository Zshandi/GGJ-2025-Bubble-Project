@tool
extends CollisionShape2D

signal pop_finished

@export
var color := Color.WHITE:
	get: return %BubbleColor.modulate
	set(value): %BubbleColor.modulate = value

@export
var wobble_on_ready := false

func start_wobble():
	%AnimationPlayer.play("wobble")

func pop():
	%AnimationPlayer.play("pop")
	%AudioPlayer_Pop.play()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if wobble_on_ready:
		start_wobble()

func _process(_delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	if anim_name == &"pop":
		pop_finished.emit()
