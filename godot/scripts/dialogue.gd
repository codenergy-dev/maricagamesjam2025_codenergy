extends Node

@export var resource: DialogueResource
@export var start: String = "start"

var started = false

@onready var raycast = $RayCast2D

func _physics_process(delta: float) -> void:
	if not started and raycast.is_colliding():
		started = true
		
		var player: Player = DialogueManager.get_current_scene.call().player
		var player_previous_state = player.state_name
		player.change_state("dialogue")
		player.controls.hide()
		
		DialogueManager.show_dialogue_balloon(resource, start)
		await DialogueManager.dialogue_ended
		
		player.change_state(player_previous_state)
		player.controls.show()
