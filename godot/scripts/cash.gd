class_name Cash
extends Node

@export var count = 0

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	count = SharedPreferences.get_int("player_cash")

func _process(delta: float) -> void:
	label.text = str(count)
