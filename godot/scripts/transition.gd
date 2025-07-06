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
	elif type.begins_with("level_select_"):
		var level = int(type.split("_")[2]) if type.split("_").size() == 3 else 0
		var level_select = get_tree().root.get_node("LevelSelect")
		
		if is_instance_valid(level_select):
			level_select.queue_free()
		elif is_instance_valid(Game.current_level):
			Game.clear_level(Game.current_level)
			Game.reset_game()
		
		if level == 0:
			get_tree().change_scene_to_file("res://scenes/levels/level_0_1.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
	elif type == "reset_level":
		Game.reset_level(Game.current_level)
