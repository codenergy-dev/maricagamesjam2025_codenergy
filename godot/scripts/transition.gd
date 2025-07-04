class_name Transition
extends Node

var type: String

@onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.play("transition")
	await animation.animation_finished
	queue_free()

func on_transition():
	if type == "load_game":
		Game.clear_level(Game.current_level)
		Game.reset_game()
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	if type == "reset_level":
		Game.reset_level(Game.current_level)
