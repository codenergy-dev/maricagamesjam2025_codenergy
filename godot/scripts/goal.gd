extends Node

var level_select: String

@onready var goal: RayCast2D = $RayCast2D

func _ready() -> void:
	if Game.will_next_level_change_base():
		level_select = Game.get_next_level_path().split("_")[1]

func _physics_process(delta: float) -> void:
	if goal.is_colliding():
		if level_select:
			TransitionManager.transition("level_select_" + level_select)
		queue_free()
