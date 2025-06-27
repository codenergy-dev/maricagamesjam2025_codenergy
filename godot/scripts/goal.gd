extends Node

@onready var goal: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	if goal.is_colliding():
		queue_free()
