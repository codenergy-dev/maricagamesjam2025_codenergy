class_name Level
extends Node2D

@export var player_sprite_frames: String = "default"

var index: int = 0
var player: Player
var reset_level = false

@onready var next = $Next

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		add_to_group("game")
	var camera: Camera2D = get_tree().get_first_node_in_group("camera")
	if not camera:
		var camera_scene = load("res://scenes/camera.tscn")
		camera = camera_scene.instantiate()
		add_child(camera)
	camera.limit_right = next.global_position.x
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_sprite_frames(player_sprite_frames)
	load_music()
	DialogueManager.get_current_scene = func():
		return self

func _physics_process(delta: float) -> void:
	if Game.current_level != self:
		return
	
	var camera: Camera2D = get_tree().get_first_node_in_group("camera")
	var camera_center = camera.get_screen_center_position()
	var camera_transform = camera.get_canvas_transform().affine_inverse()
	var camera_left = camera_transform.origin.x
	var camera_right = camera_center.x + (camera_center.x - camera_left)
	if camera_left >= global_position.x:
		camera.limit_left = global_position.x
	if camera_right >= next.global_position.x and Game.auto_level_index == index:
		var game = get_tree().get_first_node_in_group("game")
		var next_level = Game.next_level()
		camera.limit_right = 10000000
		next_level.global_position = next.global_position
		game.add_child(next_level)
	
	var player = get_tree().get_first_node_in_group("player")
	if not player and not reset_level:
		reset_level = true
		TransitionManager.transition("reset_level")

func load_music():
	var game = get_tree().get_first_node_in_group("game")
	var has_audio_stream_player = game.has_node("AudioStreamPlayer")
	if not has_audio_stream_player:
		return
	
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
