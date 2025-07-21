class_name Score
extends Node

@onready var recycle: Recycle = $Control/Recycle
@onready var cash: Cash = $Control/Cash
@onready var audio: AudioManager = $AudioManager

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	var recycle_step = 4
	var recycle_count_max = SharedPreferences.get_int("current_player_recycle")
	while recycle.count < recycle_count_max:
		recycle.count = min(recycle.count + recycle_step, recycle_count_max)
		audio.play("recycle")
		recycle.animation_player.play("bump")
		await recycle.animation_player.animation_finished
	
	await get_tree().create_timer(0.5).timeout
	var cash_step = recycle_step * 5
	var cash_count_max = recycle_count_max * 5 + cash.count
	while cash.count < cash_count_max:
		cash.count = min(cash.count + cash_step, cash_count_max)
		audio.play("cash")
		cash.animation_player.play("bump")
		await cash.animation_player.animation_finished
	SharedPreferences.set_int("player_cash", cash.count)
	
	await get_tree().create_timer(1.0).timeout
	var next_level_select = SharedPreferences.get_string("next_level_select", "1")
	TransitionManager.transition("level_select_" + next_level_select)
