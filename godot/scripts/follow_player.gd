extends CharacterBody2D

# O delay em segundos que o follower terá em relação ao jogador
@export var follow_delay: float = 0.5 

# A velocidade com que o follower se move para a posição correta (para suavizar)
@export var catch_up_speed: float = 30.0

var is_following = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# A gravidade ainda é aplicada normalmente pelo CharacterBody2D
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	if not is_following:
		move_and_slide()
		return

	# 1. Calcula qual era o tempo 'agora' menos o nosso delay.
	var target_timestamp = Time.get_ticks_msec() - (follow_delay * 1000)

	# 2. Pede ao gravador o estado do jogador naquele momento no passado.
	var target_state = PlayerRecorder.get_state_at_time(target_timestamp)

	# Se não houver estado (ex: jogo acabou de começar), não faz nada.
	if target_state.is_empty():
		move_and_slide()
		return

	# 3. Pega a posição e a direção do estado gravado.
	var target_position = target_state.position
	var target_flip_h = target_state.flip_h
	var target_velocity_y = target_state.velocity_y

	# 4. Move-se suavemente em direção à posição alvo.
	# Em vez de teletransporte, usamos lerp para um movimento mais natural.
	# Isso cria um movimento autônomo que sempre busca o ponto correto na trilha.
	global_position = global_position.lerp(target_position, catch_up_speed * delta)
	
	# 5. Atualiza a aparência para espelhar o jogador.
	animated_sprite.flip_h = target_flip_h
	
	# Gerencia as animações baseado na movimentação e no estado do pulo gravado.
	if not is_on_floor():
		animated_sprite.play("jump")
	elif global_position.distance_to(target_position) > 2: # Se estiver se movendo para o alvo
		animated_sprite.play("walk")
	else: # Se já chegou no alvo
		animated_sprite.play("idle")
	
	# Nós não controlamos mais a velocidade diretamente, mas move_and_slide()
	# ainda é útil para colisões com o chão e paredes.
	move_and_slide()

func _on_follow_area_body_entered(body):
	pass

func _on_follow_area_body_exited(body: Node2D) -> void:
	# Check if the body that entered is the player (e.g., by checking its script or group).
	# And ensure we only connect the signal once.
	if body.name == "Player" and not is_following:
		is_following = true
		PlayerRecorder.clear_player_state()
