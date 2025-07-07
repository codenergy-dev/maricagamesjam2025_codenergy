class_name Game
extends Node

static var current_level: Level
static var previous_level: Level

static var base_level_index = 0
static var auto_level_index = 0

static var preloaded_next_level: PackedScene = null

func _ready() -> void:
	add_child(next_level())

static func is_level_scene_path_valid(base, step):
	return ResourceLoader.exists("res://scenes/levels/level_" + str(base) + "_" + str(step) + ".tscn")

static func will_next_level_change_base():
	var next_level_path = get_next_level_path()
	var next_level_base_index = int(next_level_path.split("_")[1])
	return base_level_index != next_level_base_index

static func load_level_scene(base, step):
	return load("res://scenes/levels/level_" + str(base) + "_" + str(step) + ".tscn")

static func get_next_level_path() -> String:
	if is_level_scene_path_valid(base_level_index, auto_level_index + 1):
		return "res://scenes/levels/level_" + str(base_level_index) + "_" + str(auto_level_index + 1) + ".tscn"
	elif is_level_scene_path_valid(base_level_index + 1, 1):
		return "res://scenes/levels/level_" + str(base_level_index + 1) + "_" + str(1) + ".tscn"
	else:
		return "res://scenes/levels/level_1_1.tscn"

static func preload_next_level():
	if preloaded_next_level != null:
		return
		
	var path = get_next_level_path()
	if path.is_empty():
		return

	print("Iniciando pré-carregamento de: ", path)
	ResourceLoader.load_threaded_request(path)

static func next_level() -> Level:
	var path = get_next_level_path()
	var status = ResourceLoader.load_threaded_get_status(path)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		ResourceLoader.load_threaded_get(path)
	
	if not preloaded_next_level:
		preloaded_next_level = load(path)
	
	if is_level_scene_path_valid(base_level_index, auto_level_index + 1):
		auto_level_index += 1
	elif is_level_scene_path_valid(base_level_index + 1, 1):
		base_level_index += 1
		auto_level_index = 1
	else:
		base_level_index = 1
		auto_level_index = 1
	
	var next_level = preloaded_next_level.instantiate()
	next_level.index = auto_level_index
	preloaded_next_level = null
	preload_next_level()
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
