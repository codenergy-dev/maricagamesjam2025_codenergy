class_name Transition
extends Node

var type: String

@onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.play("transition")
	await animation.animation_finished
	queue_free()

func on_transition():
	if type == "title":
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	elif type == "start_game":
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	elif type == "level_select":
		Game.clear_level(Game.current_level)
		Game.reset_game()
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")
	elif type.begins_with("level_select_"):
		var level = int(type.split("_")[2]) if type.split("_").size() == 3 else 0
		var level_select = get_tree().root.get_node("LevelSelect")
		var score = get_tree().root.get_node("Score")
		
		if is_instance_valid(level_select):
			level_select.queue_free()
		elif is_instance_valid(Game.current_level):
			Game.clear_level(Game.current_level)
			Game.reset_game()
		
		if is_instance_valid(score):
			score.queue_free()
		
		Game.base_level_index = level
		Game.auto_level_index = 0
		
		SharedPreferences.set_int("current_player_recycle", 0)
		get_tree().root.add_child(Game.next_level())
	elif type == "reset_level":
		Game.reset_level(Game.current_level)
	elif type == "score":
		var current_player_recycle = SharedPreferences.get_int("current_player_recycle")
		var next_level_select = SharedPreferences.get_string("next_level_select")
		if not current_player_recycle:
			type = "level_select_" + next_level_select
			on_transition()
		else:
			Game.clear_level(Game.current_level)
			Game.reset_game()
			get_tree().change_scene_to_file("res://scenes/score.tscn")
