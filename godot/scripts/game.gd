class_name Game
extends Node

@export var levels: Array[PackedScene] = []

static var current_levels: Array[PackedScene] = []
static var current_level: Level
static var previous_level: Level

static var auto_level_index = -1

func _ready() -> void:
	current_levels = levels
	add_child(next_level())

static func next_level() -> Level:
	if auto_level_index + 1 >= current_levels.size():
		auto_level_index = 0
	else:
		auto_level_index += 1
	var next_level: Level = current_levels[auto_level_index].instantiate()
	next_level.index = auto_level_index
	return next_level

static func set_current_level(level: Level):
	if current_levels.size() == 0:
		auto_level_index = 0
		current_levels = [load(level.scene_file_path)]
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
