class_name Game
extends Node

static var current_level: Level
static var previous_level: Level

static var base_level_index = 0
static var auto_level_index = 0

func _ready() -> void:
	add_child(next_level())

static func is_level_scene_path_valid(base, step):
	return ResourceLoader.exists("res://scenes/levels/level_" + str(base) + "_" + str(step) + ".tscn")

static func load_level_scene(base, step):
	return load("res://scenes/levels/level_" + str(base) + "_" + str(step) + ".tscn")

static func next_level() -> Level:
	if is_level_scene_path_valid(base_level_index, auto_level_index + 1):
		auto_level_index += 1
	elif is_level_scene_path_valid(base_level_index + 1, 1):
		base_level_index += 1
		auto_level_index = 1
	else:
		base_level_index = 1
		auto_level_index = 1
	var next_level: Level = load_level_scene(base_level_index, auto_level_index).instantiate()
	next_level.index = auto_level_index
	return next_level

static func set_current_level(level: Level):
	base_level_index = int(level.scene_file_path.split("_")[1])
	auto_level_index = int(level.scene_file_path.split("_")[2])
	current_level = level

static func reset_level(level: Level):
	clear_level(level)
	reset_game(level.index - 1)
	var game = level.get_tree().get_first_node_in_group("game")
	game.add_child(next_level())

static func reset_game(auto_level_index: int = -1):
	current_level = null
	previous_level = null
	Game.auto_level_index = auto_level_index

static func clear_level(level: Level):
	var game = level.get_tree().get_first_node_in_group("game")
	var children = game.get_children()
	for child in children:
		if child is AudioStreamPlayer:
			continue
		elif child is DialogueManager:
			continue
		elif child is PlayerRecorder:
			continue
		elif child is Transition:
			continue
		elif child is TransitionManager:
			continue
		child.queue_free()

static func queue_free_previous_level():
	if is_instance_valid(previous_level):
		for spawn_instance in previous_level.spawn_instances:
			if is_instance_valid(spawn_instance) and not spawn_instance.is_in_group("player"):
				spawn_instance.queue_free()
		previous_level.queue_free()
