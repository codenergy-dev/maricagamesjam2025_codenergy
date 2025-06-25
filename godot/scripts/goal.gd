extends Node

@onready var goal: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if goal.is_colliding():
		var player = goal.get_collider()
		var game = get_tree().get_first_node_in_group("game")
		var next = game.find_children("Next", "", true, false)[-1]
		var next_level = Game.next_level()
		next_level.global_position = next.global_position
		game.add_child(next_level)
		queue_free()
