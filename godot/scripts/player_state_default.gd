extends PlayerState

@export var speed = 1000.0
@export var jump_height: float = 400.0 # Altura do pulo em pixels
@export var time_to_peak: float = 0.4   # Tempo para atingir o pico do pulo em segundos
@export var time_to_fall: float = 0.3   # Tempo para cair do pico (menor para cair mais rápido)

func physics_process(delta):
	player.rotation = 0
	
	# Add the gravity.
	if not player.is_on_floor():
		if player.velocity.y > 0: # Caindo
			player.velocity.y += get_fall_gravity() * delta
			player.animated_sprite.play("knockback")
		else: # Subindo
			player.velocity.y += get_jump_gravity() * delta
			if player.animated_sprite.animation != "knockback":
				player.animated_sprite.play("jump")

	# Handle jump.
	if player.knockback.is_zero() and Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.velocity.y = -get_jump_velocity()
		player.action_taken.emit({"type": "jump"})
		player.animated_sprite.play("jump")
		player.audio.play("jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if player.knockback.is_zero() and direction:
		player.velocity.x = direction * speed
		player.action_taken.emit({"type": "move", "direction": direction})
		player.animated_sprite.flip_h = direction > 0
		if player.is_on_floor():
			player.animated_sprite.play("walk")
	elif player.knockback.is_zero():
		if player.velocity.x != 0:
			player.action_taken.emit({"type": "move", "direction": 0})
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		if player.is_on_floor():
			player.animated_sprite.play("idle")

	player.velocity += player.knockback.knockback
	
	player.move_and_slide()
	
	PlayerRecorder.record_player_state(player.global_position, player.animated_sprite.flip_h, player.velocity.y)
	
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("hitbox"):
			var knockback_direction = collision.get_normal()
			player.apply_knockback(knockback_direction)
			break

func on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		player.velocity.y = -get_jump_velocity()
		player.animated_sprite.play("jump")

func get_jump_velocity() -> float:
	return (2.0 * jump_height) / time_to_peak

func get_jump_gravity() -> float:
	return (2.0 * jump_height) / (time_to_peak * time_to_peak)

func get_fall_gravity() -> float:
	return (2.0 * jump_height) / (time_to_fall * time_to_fall)
