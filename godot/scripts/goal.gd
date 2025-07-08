extends Node

var level_select: String

@onready var goal: RayCast2D = $RayCast2D

func _ready() -> void:
	if Game.will_next_level_change_base():
		level_select = Game.get_next_level_path().split("_")[1]

func _physics_process(delta: float) -> void:
	if goal.is_colliding():
		if level_select:
			var player: Player = goal.get_collider()
			player.joystick._reset()
			SharedPreferences.set_int("current_player_recycle", player.recycle.count)
			SharedPreferences.set_string("next_level_select", level_select)
			TransitionManager.transition("score")
		queue_free()
