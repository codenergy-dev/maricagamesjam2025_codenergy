class_name Player
extends CharacterBody2D

signal action_taken(action_details)

@export var lives = 3
@export var state_name: String = "default"
@export var state_scripts: Dictionary[String, Script]

var state: PlayerState
var state_instances: Dictionary[String, PlayerState]

@onready var animated_sprite = $AnimatedSprite2D
@onready var knockback = $Knockback
@onready var flash = $Flash

func _ready() -> void:
	for state_script in state_scripts:
		var state_instance = state_scripts[state_script].new()
		state_instance.player = self
		state_instances[state_script] = state_instance
	state = state_instances[state_name]

func _physics_process(delta: float) -> void:
	if lives <= 0 and knockback.is_zero():
		queue_free()
	state.physics_process(delta)

func _on_knockback_body_entered(body: Node2D) -> void:
	if body is not TileMapLayer and body.is_in_group("hitbox"):
		var knockback_direction = (global_position - body.global_position).normalized()
		apply_knockback(knockback_direction)

func _on_knockback_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		var knockback_direction = (global_position - area.global_position).normalized()
		apply_knockback(knockback_direction)

func _on_hitbox_area_entered(area: Area2D) -> void:
	state.on_hitbox_area_entered(area)

func _on_body_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		state = state_instances["swim"]

func _on_body_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("water"):
		state = state_instances["default"]

func apply_knockback(direction: Vector2):
	lives -= 1
	knockback.apply_knockback(direction)
	flash.start_flash()
	animated_sprite.play("knockback")
