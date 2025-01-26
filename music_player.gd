extends Node

var audio_player:AudioStreamPlayer

var playing := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	#audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(audio_player)
	audio_player.stream = preload("res://assets/music/whispering-vinyl-loops-lofi-beats-281193.mp3")
	audio_player.finished.connect(_audio_player_finished)
	
	# TODO: Only play once game is started
	await audio_player.tree_entered
	play()

func play() -> void:
	if !playing:
		playing = true
		audio_player.play()

func stop():
	playing = false
	audio_player.stop()

func _audio_player_finished():
	if playing:
		await get_tree().create_timer(27).timeout
		if playing and !audio_player.playing:
			audio_player.play()
