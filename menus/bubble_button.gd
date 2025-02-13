extends Area2D

@export_file("*.tscn")
var load_scene_path:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			$BubbleCollision.pop()
			await $BubbleCollision.pop_finished
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_packed(load(load_scene_path))
			MusicPlayer.play()
