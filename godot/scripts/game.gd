class_name Game
extends Node

@export var levels: Array[PackedScene] = []

static var current_levels: Array[PackedScene] = []
static var current_level: Level

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
	var game = level.get_tree().get_first_node_in_group("game")
	var children = game.get_children()
	for child in children:
		if child.name not in ["Camera", "AudioStreamPlayer", "Transition"]:
			child.queue_free()
	
	auto_level_index = level.index - 1
	game.add_child(next_level())
