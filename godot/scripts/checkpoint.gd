extends Node

@onready var checkpoint: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if checkpoint.is_colliding():
		var level = get_tree().get_nodes_in_group("level")[-1]
		level.current_level = level
