extends Camera2D

var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	if player:
		position = player.global_position
	else:
		player = get_tree().get_first_node_in_group("player")
