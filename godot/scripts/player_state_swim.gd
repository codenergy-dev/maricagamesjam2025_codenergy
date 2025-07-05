# EstadoNadando.gd
extends PlayerState

@export_group("Natação")
@export var swim_speed = 125.0 # Velocidade de nado em qualquer direção
@export var rotation_speed = 5.0
@export var water_drag = 5.0  # Quão rápido o player para na água. Maior = mais arrasto.

@export_group("Pulo para Fora d'Água")
@export var water_exit_jump_force = -250.0 # Um impulso forte para sair da água

func physics_process(delta):
	# --- MOVIMENTO DIRECIONAL ---
	
	# 1. Pega o input das 4 direções (esquerda, direita, cima, baixo)
	#    Ele já retorna um vetor normalizado, o que previne movimento diagonal mais rápido.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. Define a velocidade alvo baseado no input.
	#    Se nenhuma tecla for pressionada, o alvo é (0,0), fazendo o player parar.
	var target_velocity = input_direction * swim_speed
	
	if input_direction != Vector2.ZERO:
		# 1. Pega o ângulo do vetor de direção (em radianos).
		var target_angle = input_direction.angle() + deg_to_rad(90.0)
		
		# 2. Interpola suavemente a rotação atual em direção ao ângulo alvo.
		#    lerp_angle é a função correta para ângulos, pois lida com a volta de 2*PI para 0.
		player.rotation = lerp_angle(player.rotation, target_angle, rotation_speed * delta)
	else:
		player.rotation = lerp_angle(player.rotation, 0, rotation_speed * delta)
	
	# --- APLICAÇÃO DA VELOCIDADE E ARRASTO (DRAG) ---
	# Usamos lerp para mover a velocidade atual em direção à velocidade alvo.
	# Isso cria uma aceleração suave e o efeito de "arrasto" da água quando paramos.
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, water_drag * delta)
	player.velocity.y = lerp(player.velocity.y, target_velocity.y, water_drag * delta)

	# --- PULO PARA SAIR DA ÁGUA ---
	# Este pulo tem prioridade e sobrepõe a velocidade vertical.
	if Input.is_action_just_pressed("ui_accept"):
		player.velocity = (-input_direction if input_direction != Vector2.ZERO else Vector2(0, 1)) * water_exit_jump_force
		# Poderia adicionar um som de pulo na água aqui, ou um efeito de splash
		player.action_taken.emit({"type": "water_jump"})


	# --- ANIMAÇÃO ---
	# Atualiza animações e a direção do sprite
	update_animation(input_direction)
		
	player.move_and_slide()

func update_animation(direction: Vector2):
	# Se o player estiver se movendo (o vetor de direção não é zero)
	if direction != Vector2.ZERO:
		player.animated_sprite.play("swim") # Supondo que você tenha uma animação para nadar
		# Só vira o sprite se houver movimento horizontal
		if direction.x != 0:
			player.animated_sprite.flip_h = direction.x > 0
	else:
		# Se estiver parado, toca a animação de idle na água
		player.animated_sprite.play("float")
