extends CollisionShape2D

signal pop_finished

@export
var color := Color.WHITE:
	get: return %BubbleColor.modulate
	set(value): %BubbleColor.modulate = value

func start_wobble():
	$AnimationPlayer.play("wobble")

func pop():
	$AnimationPlayer.play("pop")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"pop":
		pop_finished.emit()
