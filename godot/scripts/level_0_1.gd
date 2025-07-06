extends Level

@onready var audio: AudioManager = $AudioManager

func arcade_abducts_player():
	var arcade: Arcade = get_tree().get_first_node_in_group("game").find_child("Arcade", true, false)
	audio.play("abduction")
	arcade.animation_player.play("abducts_player")
	player.animation_player.play("abducted")
	await arcade.animation_player.animation_finished
	TransitionManager.transition("level_select_1")
