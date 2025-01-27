extends Node2D

@export
var next_level_scene:PackedScene = null

@export_file("*.tscn")
var next_level_path:String = ""

@export
var complete_wait_seconds:float = 1.5

var collectible_count:int = 0

signal complete_timeout_started
signal completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for collectible in get_tree().get_nodes_in_group("LevelPassCollectible"):
		collectible_count += 1
		collectible.connect("tree_exited", _collectible_on_tree_exited)

func _collectible_on_tree_exited():
	collectible_count -= 1
	if collectible_count <= 0:
		level_complete()

func level_complete():
	if !is_inside_tree(): return
	complete_timeout_started.emit()
	await get_tree().create_timer(complete_wait_seconds).timeout
	if !%BubbleCharacter.is_dead:
		completed.emit()
		#assert(next_level_scene != null)
		if (next_level_scene == null && next_level_path != ""):
			next_level_scene = load(next_level_path)
		if (next_level_scene == null): return
		var next_level := next_level_scene.instantiate()
		# Sound transition
		var audio_player = AudioStreamPlayer.new()
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.stream = preload("res://assets/sounds/Lots and lots of bubbles popping (short fade).wav")
		get_tree().root.add_child(audio_player)
		audio_player.play()
		# Delay so the sound starts before next level loads
		get_tree().paused = true
		await get_tree().create_timer(1).timeout
		get_tree().paused = false
		# TODO: Maybe we should have some kind of transition?
		get_tree().root.add_child(next_level)
		next_level.owner = get_tree().root
		get_tree().current_scene = next_level
		queue_free()
		
		await audio_player.finished
		audio_player.queue_free()
