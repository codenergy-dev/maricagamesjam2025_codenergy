extends Node

@export var resource: DialogueResource
@export var start: String = "start"

var started = false

@onready var raycast = $RayCast2D

func _physics_process(delta: float) -> void:
	if not started and raycast.is_colliding():
		started = true
		DialogueManager.show_dialogue_balloon(resource, start)
