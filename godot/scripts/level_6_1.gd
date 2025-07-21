extends Level

@export var dialogue: DialogueResource

var arcade_laser_count = 0
var arcade_laser_count_max = 5

func activate_arcade():
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	arcade.laser.enable_auto_shoot()
	
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.name = "Charge"
	audio_stream_player.stream = load("res://assets/sounds/laser_charge.wav")
	arcade.laser.audio.add_child(audio_stream_player)
	arcade.laser.audio.sounds["charge"] = audio_stream_player
	arcade.laser.animation_player.connect("animation_started", on_arcade_animation_started)
	arcade.laser.animation_player.connect("animation_finished", on_arcade_animation_finished)
	
	load_music(5)

func on_arcade_animation_started(animation: String):
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	if animation == "charge":
		arcade.laser.animation_player.speed_scale = 1.0
		arcade.laser.audio.play("charge")
	elif animation == "beam":
		arcade_laser_count += 1
		arcade.laser.animation_player.speed_scale = 2.0

func on_arcade_animation_finished(animation: String):
	var player: Player = get_tree().get_first_node_in_group("player")
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	if arcade_laser_count == arcade_laser_count_max:
		arcade.laser.disable_auto_shoot()
		
		DialogueManager.show_dialogue_balloon(dialogue, "final")
		await DialogueManager.dialogue_ended
		
		arcade.animation_player.play("abducts_player")
		player.animation_player.play("abducted")
		await arcade.animation_player.animation_finished
		
		TransitionManager.transition("title")
