class_name Player
extends CharacterBody2D

signal action_taken(action_details)

@export var lives = 3
@export var state_name: String = "default"
@export var state_scripts: Dictionary[String, Script]
@export var sprite_frames: Dictionary[String, SpriteFrames]

var state: PlayerState
var state_instances: Dictionary[String, PlayerState]

@onready var animated_sprite = $AnimatedSprite2D
@onready var knockback = $Knockback
@onready var flash = $Flash
@onready var audio: AudioManager = $AudioManager

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

func _on_body_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("water"):
		change_state("swim")
		audio.play("splash")

func _on_body_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("water"):
		change_state("default")

func change_state(new_state_name: String):
	if state_name == new_state_name:
		return
	
	if state and state.has_method("exit"):
		state.exit()
	
	state_name = new_state_name
	state = state_instances[new_state_name]
	
	if state and state.has_method("enter"):
		state.enter()

func apply_knockback(direction: Vector2):
	lives -= 1
	knockback.apply_knockback(direction)
	flash.start_flash()
	animated_sprite.play("knockback")
	audio.play("knockback")

func set_sprite_frames(sprite_frames: String):
	var current_animation = animated_sprite.animation
	var current_frame = animated_sprite.frame
	var is_playing = animated_sprite.is_playing()

	animated_sprite.sprite_frames = self.sprite_frames[sprite_frames]

	if is_playing:
		animated_sprite.play(current_animation)
	animated_sprite.frame = current_frame
