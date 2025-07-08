extends Node

var has_started_game = false

@onready var audio = $AudioManager

func _ready() -> void:
	var game = get_tree().root
	game.add_to_group("game")
	
	var has_audio_stream_player = game.has_node("AudioStreamPlayer")
	if not has_audio_stream_player:
		var audio_stream_player = AudioStreamPlayer.new()
		audio_stream_player.name = "AudioStreamPlayer"
		audio_stream_player.stream = load("res://assets/music/title.wav")
		audio_stream_player.autoplay = true
		game.add_child.call_deferred(audio_stream_player)

func _on_button_pressed() -> void:
	start_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().quit()
	elif event is InputEventKey and event.pressed and not event.echo:
		start_game()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

func start_game() -> void:
	if has_started_game:
		return
	has_started_game = true
	audio.play("select")
	TransitionManager.transition("start_game")
