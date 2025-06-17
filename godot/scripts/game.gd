extends Node

@export var levels: Array[PackedScene]

var current_level = -1

func _ready() -> void:
	var level_scene = next_level()
	var level_instance = level_scene.instantiate()
	add_child(level_instance)

func next_level() -> PackedScene:
	if current_level + 1 >= levels.size():
		return null
	current_level += 1
	return levels[current_level]
