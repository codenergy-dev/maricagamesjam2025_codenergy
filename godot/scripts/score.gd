class_name Score
extends Node

@onready var recycle: Recycle = $Control/Recycle
@onready var cash: Cash = $Control/Cash
@onready var audio: AudioManager = $AudioManager

func _ready() -> void:
	var recycle_step = 10
	var recycle_count_max = recycle.count
	recycle.count = 0
	while recycle.count < recycle_count_max:
		recycle.count = min(recycle.count + recycle_step, recycle_count_max)
		audio.play("recycle")
		recycle.animation_player.play("bump")
		await recycle.animation_player.animation_finished
	
	var cash_step = recycle_step * 5
	var cash_count_max = recycle_count_max * 5
	while cash.count < cash_count_max:
		cash.count = min(cash.count + cash_step, cash_count_max)
		audio.play("cash")
		cash.animation_player.play("bump")
		await cash.animation_player.animation_finished
