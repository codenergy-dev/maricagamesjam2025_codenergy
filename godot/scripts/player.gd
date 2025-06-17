extends CharacterBody2D

signal action_taken(action_details)

@onready var animated_sprite = $AnimatedSprite2D
@onready var knockback = $Knockback
@onready var flash = $Flash

const SPEED = 600.0

# Adicione estas variáveis exportadas para ajustar no Inspetor
@export var JUMP_HEIGHT: float = 240.0 # Altura do pulo em pixels
@export var TIME_TO_PEAK: float = 0.4   # Tempo para atingir o pico do pulo em segundos
@export var TIME_TO_FALL: float = 0.3   # Tempo para cair do pico (menor para cair mais rápido)

# Variáveis que serão calculadas
@onready var jump_velocity: float = (2.0 * JUMP_HEIGHT) / TIME_TO_PEAK
@onready var jump_gravity: float = (2.0 * JUMP_HEIGHT) / (TIME_TO_PEAK * TIME_TO_PEAK)
@onready var fall_gravity: float = (2.0 * JUMP_HEIGHT) / (TIME_TO_FALL * TIME_TO_FALL)

var lives = 1

func _physics_process(delta: float) -> void:
	if lives <= 0 and knockback.is_zero():
		queue_free()
	
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0: # Caindo
			velocity.y += fall_gravity * delta
			animated_sprite.play("knockback")
		else: # Subindo
			velocity.y += jump_gravity * delta
			if animated_sprite.animation != "knockback":
				animated_sprite.play("jump")

	# Handle jump.
	if knockback.is_zero() and Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_velocity
		action_taken.emit({"type": "jump"})
		animated_sprite.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if knockback.is_zero() and direction:
		velocity.x = direction * SPEED
		action_taken.emit({"type": "move", "direction": direction})
		animated_sprite.flip_h = direction > 0
		if is_on_floor():
			animated_sprite.play("walk")
	elif knockback.is_zero():
		if velocity.x != 0:
			action_taken.emit({"type": "move", "direction": 0})
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animated_sprite.play("idle")

	velocity += knockback.knockback
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("hitbox"):
			var knockback_direction = collision.get_normal()
			apply_knockback(knockback_direction)
			break

func _on_knockback_body_entered(body: Node2D) -> void:
	if body is not TileMapLayer and body.is_in_group("hitbox"):
		var knockback_direction = (global_position - body.global_position).normalized()
		apply_knockback(knockback_direction)

func _on_knockback_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		var knockback_direction = (global_position - area.global_position).normalized()
		apply_knockback(knockback_direction)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		velocity.y = -jump_velocity
		animated_sprite.play("jump")

func apply_knockback(direction: Vector2):
	lives -= 1
	knockback.apply_knockback(direction)
	flash.start_flash()
	animated_sprite.play("knockback")
