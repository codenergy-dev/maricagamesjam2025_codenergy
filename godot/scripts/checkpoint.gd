extends Node

@onready var checkpoint: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if checkpoint.is_colliding():
		var next_level = get_tree().get_nodes_in_group("level")[-1]
		Game.previous_level = Game.current_level
		Game.set_current_level(next_level)
		queue_free()
