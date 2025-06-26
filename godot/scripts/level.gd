class_name Level
extends Node

@export var player_sprite_frames: String = "default"

var index: int = 0

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		add_to_group("game")
	var camera = get_tree().get_first_node_in_group("camera")
	if not camera:
		var camera_scene = load("res://scenes/camera.tscn")
		var camera_instance = camera_scene.instantiate()
		add_child(camera_instance)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_sprite_frames(player_sprite_frames)
	load_music()

func _physics_process(delta: float) -> void:
	if Game.current_level != self:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		Game.reset_level(self)

func load_music():
	var game = get_tree().get_first_node_in_group("game")
	var audio_stream_player: AudioStreamPlayer = game.get_node("AudioStreamPlayer")
	if audio_stream_player:
		var level = int(scene_file_path.split("/")[-1].split("_")[1])
		var music: Dictionary[int, String] = {
			1: "res://assets/music/level_forest.wav",
			2: "res://assets/music/level_sea.wav",
		}
		if not audio_stream_player.stream or audio_stream_player.stream.resource_path != music[level]:
			audio_stream_player.stop()
			audio_stream_player.stream = load(music[level])
			audio_stream_player.play()
