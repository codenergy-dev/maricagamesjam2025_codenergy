extends Node

@export var player_sprite_frames: String = "default"

static var current_level: Node

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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_sprite_frames(player_sprite_frames)

func _physics_process(delta: float) -> void:
	if current_level != self:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		var game = get_tree().get_first_node_in_group("game")
		var children = game.get_children()
		for child in children:
			if child.name != "Camera":
				child.queue_free()
		
		var level_scene = load(scene_file_path)
		var level_instance = level_scene.instantiate()
		game.add_child(level_instance)
