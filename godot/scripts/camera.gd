extends Camera2D

var player: CharacterBody2D

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player:
		position = player.global_position
