extends Node

@onready var music = $AudioStreamPlayer
@onready var audio = $AudioManager

func _ready() -> void:
	get_tree().root.add_to_group("game")

func _on_button_pressed() -> void:
	audio.play("select")
	await AudioFade.out(music)
	TransitionManager.transition("start_game")
