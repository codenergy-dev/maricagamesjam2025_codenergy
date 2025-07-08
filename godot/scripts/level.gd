class_name Level
extends Node2D

@export var load_next_level: bool = true
@export var player_state: String = "default"
@export var player_sprite_frames: String = "default"
@export var player_light_enabled: bool = false
@export var player_hud_enabled: bool = true

var index: int = 0
var player: Player
var reset_level = false
var spawn_instances: Array[Node] = []

@onready var next = $Next

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		game = get_tree().root
		game.add_to_group("game")
	var camera: Camera2D = get_tree().get_first_node_in_group("camera")
	if not camera:
		var camera_scene = load("res://scenes/camera.tscn")
		camera = camera_scene.instantiate()
		game.add_child(camera)
	camera.limit_right = next.global_position.x
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.change_state(player_state)
		player.get_node("Light").visible = player_light_enabled
		player.get_node("HUD").visible = player_hud_enabled
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
		Game.queue_free_previous_level()
	if load_next_level and is_instance_valid(next) and camera_right >= next.global_position.x and Game.auto_level_index == index:
		load_next_level = false
		_load_next_level()
	
	var player = get_tree().get_first_node_in_group("player")
	if not player and not reset_level:
		reset_level = true
		TransitionManager.transition("reset_level")

func _load_next_level():
	if Game.will_next_level_change_base():
		return
	var game = get_tree().get_first_node_in_group("game")
	var camera: Camera2D = get_tree().get_first_node_in_group("camera")
	var next_level = Game.next_level()
	camera.limit_right = 10000000
	next_level.global_position = next.global_position
	next.queue_free()
	game.add_child(next_level)

func load_music():
	var game = get_tree().get_first_node_in_group("game")
	var has_audio_stream_player = game.has_node("AudioStreamPlayer")
	if not has_audio_stream_player:
		var audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.name = "AudioStreamPlayer"
		game.add_child(audio_stream_player)
	
	var audio_stream_player: AudioStreamPlayer = game.get_node("AudioStreamPlayer")
	if audio_stream_player:
		var level = int(scene_file_path.split("/")[-1].split("_")[1])
		var music: Dictionary[int, String] = {
			0: "res://assets/music/level_office.wav",
			1: "res://assets/music/level_forest.wav",
			2: "res://assets/music/level_sea.wav",
			5: "res://assets/music/level_sky.wav",
		}
		if not music.has(level):
			return
		if not audio_stream_player.stream or audio_stream_player.stream.resource_path != music[level]:
			if audio_stream_player.playing:
				await AudioFade.out(audio_stream_player, 0.25)
			audio_stream_player.stop()
			audio_stream_player.volume_db = 0
			audio_stream_player.stream = load(music[level])
			audio_stream_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		TransitionManager.transition("level_select")
