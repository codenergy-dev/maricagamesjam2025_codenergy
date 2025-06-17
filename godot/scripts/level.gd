extends Node

func _ready():
	add_to_group("level")
	await get_tree().process_frame
	var game = get_tree().get_first_node_in_group("game")
	if not game:
		var camera = Camera2D.new()
		camera.position = Vector2(0, -192)
		camera.zoom = Vector2(0.75, 0.75)
		add_child(camera)
		add_to_group("game")
