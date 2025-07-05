class_name Transition
extends Node

var type: String

@onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.play("transition")
	await animation.animation_finished
	queue_free()

func on_transition():
	if type == "start_game":
		get_tree().root.get_node("Title").queue_free()
		get_tree().change_scene_to_file("res://scenes/levels/level_0_1.tscn")
	elif type == "load_game":
		Game.clear_level(Game.current_level)
		Game.reset_game()
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	elif type == "reset_level":
		Game.reset_level(Game.current_level)
