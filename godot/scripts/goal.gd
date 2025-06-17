extends Node

@onready var goal: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if goal.is_colliding():
		var player = goal.get_collider()
		var game = get_tree().get_first_node_in_group("game")
		var level = get_tree().get_nodes_in_group("level")[-1]
		var next = level.find_child("Next")
		var next_level_scene = load(level.scene_file_path)
		var next_level_instance = next_level_scene.instantiate()
		next_level_instance.global_position = next.global_position
		game.add_child(next_level_instance)
		queue_free()
