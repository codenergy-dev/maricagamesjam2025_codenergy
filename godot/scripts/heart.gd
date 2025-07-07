extends Node

@export var count = 0

var player: Player
var gone = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player.lives == count:
		animation_player.play("pulse")
	else:
		animation_player.play("idle")

func _process(delta: float) -> void:
	if player.lives == count and animation_player.current_animation != "pulse":
		animation_player.play("pulse")
	elif player.lives < count and not gone:
		gone = true
		animation_player.play("gone")
