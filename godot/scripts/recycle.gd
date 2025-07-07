extends Node

var player: Player
var count = 0

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	label.text = str(player.collected)
	if count != player.collected:
		count = player.collected
		animation_player.play("bump")
