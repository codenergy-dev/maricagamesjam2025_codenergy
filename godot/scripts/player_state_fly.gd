# Supondo que este é o seu script de estado para o movimento "auto-runner" / "shmup"
extends PlayerState

@export_group("Velocidades")
@export var move_speed_x: float = 200.0  # Renomeado para clareza
@export var move_speed_y: float = 300.0  # Renomeado para clareza

@export_group("Suavização")
# Controla quão rápido o player atinge a velocidade máxima (aceleração/desaceleração)
@export var acceleration: float = 8.0

func physics_process(delta: float):
	# --- Input do Jogador ---

	# 1. Pega o input vertical. Input.get_axis retorna:
	#    -1 se "ui_up" (seta para cima/W) for pressionado
	#    +1 se "ui_down" (seta para baixo/S) for pressionado
	#     0 se nada ou ambos forem pressionados
	var vertical_input = Input.get_axis("ui_up", "ui_down")

	# --- Cálculo da Velocidade Alvo ---

	# 2. Define a velocidade que queremos alcançar neste frame.
	#    O eixo X é sempre a velocidade constante para a direita.
	#    O eixo Y é o input vertical multiplicado pela velocidade Y.
	var target_velocity = Vector2(move_speed_x, vertical_input * move_speed_y)

	# --- Suavização (Lerp) ---

	# 3. Interpola suavemente a velocidade ATUAL em direção à velocidade ALVO.
	#    Este é o coração do movimento suave. Em vez de saltar para a nova velocidade
	#    instantaneamente, ele se move em direção a ela.
	player.velocity = player.velocity.lerp(target_velocity, acceleration * delta)
	
	var target_angle = Vector2(1, 0).angle() + deg_to_rad(90.0)
	player.rotation = target_angle
	player.laser.rotation = -target_angle

	# --- Ações ---
	# Sua lógica de tiro continua funcionando perfeitamente aqui
	if player.laser.is_ready_to_shoot:
		if Input.is_action_just_pressed("ui_accept"):
			player.laser.shoot()
	
	if player.laser.animation_player.is_playing():
		player.animated_sprite.play("shoot")
	else:
		player.animated_sprite.play("fly")
	
	# --- Aplica o Movimento ---
	# move_and_slide() pega a 'velocity' final e move o personagem, lidando com colisões.
	player.move_and_slide()
