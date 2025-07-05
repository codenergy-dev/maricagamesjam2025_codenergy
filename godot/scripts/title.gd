extends Node

@onready var music = $AudioStreamPlayer
@onready var audio = $AudioManager

func _ready() -> void:
	get_tree().root.add_to_group("game")

func _on_button_pressed() -> void:
	audio.play("select")
	await fade_out_music()
	TransitionManager.transition("start_game")

func fade_out_music(duration := 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80, duration)
	return tween.finished
