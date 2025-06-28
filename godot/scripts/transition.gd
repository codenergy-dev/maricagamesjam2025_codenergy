class_name Transition
extends Node

var type: String

@onready var animation = $AnimationPlayer

func _ready() -> void:
	animation.play("transition")
	await animation.animation_finished
	queue_free()

func on_transition():
	if type == "reset_level":
		Game.reset_level(Game.current_level)
