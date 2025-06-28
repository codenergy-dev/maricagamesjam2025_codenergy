extends Node

func transition(type: String):
	var game = get_tree().get_first_node_in_group("game")
	var transition: Transition = load("res://scenes/transition.tscn").instantiate()
	transition.type = type
	game.add_child(transition)
