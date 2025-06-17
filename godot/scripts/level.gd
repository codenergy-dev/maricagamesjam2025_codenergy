extends Node

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		var camera_scene = load("res://scenes/camera.tscn")
		var camera_instance = camera_scene.instantiate()
		add_child(camera_instance)
		add_to_group("game")
