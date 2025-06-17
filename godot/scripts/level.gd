extends Node

static var current_level: Node

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		var camera_scene = load("res://scenes/camera.tscn")
		var camera_instance = camera_scene.instantiate()
		add_child(camera_instance)
		add_to_group("game")

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
