extends Level

func activate_arcade():
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	arcade.laser.enable_auto_shoot()
	
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.name = "Charge"
	audio_stream_player.stream = load("res://assets/sounds/laser_charge.wav")
	arcade.laser.audio.add_child(audio_stream_player)
	arcade.laser.audio.sounds["charge"] = audio_stream_player
	arcade.laser.animation_player.connect("animation_started", on_arcade_animation_started)

func on_arcade_animation_started(animation: String):
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	if animation == "charge":
		arcade.laser.animation_player.speed_scale = 1.0
		arcade.laser.audio.play("charge")
	elif animation == "beam":
		arcade.laser.animation_player.speed_scale = 2.0
