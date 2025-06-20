# EstadoNadando.gd
extends PlayerState

@export var swim_speed = 300.0
@export var swim_up_force = -400.0
@export var water_drag = 3.0 # Maior = mais arrasto
@export var buoyancy = -50.0 # Pequena força que empurra para cima

func physics_process(delta):
	# Aplica flutuabilidade em vez de gravidade
	player.velocity.y += buoyancy * delta

	# Input do jogador
	var direction = Input.get_axis("ui_left", "ui_right")
	player.velocity.x = direction * swim_speed

	if Input.is_action_pressed("ui_accept"): # "Pular" é nadar para cima
		player.velocity.y = swim_up_force

	# Aplica arrasto para desacelerar
	player.velocity = player.velocity.lerp(Vector2.ZERO, water_drag * delta)

	# Atualiza animações e flip
	if direction != 0:
		player.animated_sprite.play("swim_move")
		player.animated_sprite.flip_h = direction > 0
	else:
		player.animated_sprite.play("swim_idle")
		
	player.move_and_slide()
