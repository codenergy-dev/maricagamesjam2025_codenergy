extends Node

var has_started_game = false

@onready var music = $AudioStreamPlayer
@onready var audio = $AudioManager

func _ready() -> void:
	get_tree().root.add_to_group("game")

func _on_button_pressed() -> void:
	start_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		start_game()

func start_game() -> void:
	if has_started_game:
		return
	has_started_game = true
	audio.play("select")
	await AudioFade.out(music)
	TransitionManager.transition("start_game")
