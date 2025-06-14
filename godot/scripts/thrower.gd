extends Node2D

signal throw()

@export var projectile_scene: PackedScene
@export var target_node: Node2D

# NOVO: Defina o ângulo de lançamento em graus. 
# 45 graus oferece o maior alcance em terreno plano.
# Ângulos maiores (como 60-70) criam arcos mais altos e "lentos".
@export var launch_angle_degrees: float = 60.0

# REMOVIDO: A velocidade de lançamento não é mais fixa.
# var launch_speed = 600.0 

# Variáveis de controle de tempo
@export var launch_interval: float = 2.0
@export var trajectory_point_count = 50
var time_since_launch: float = 0.0

@onready var launch_point = $LaunchPoint
@onready var trajectory_line = $TrajectoryLine

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# A função _process permanece a mesma
func _process(delta):
	update_trajectory()
	time_since_launch += delta
	if time_since_launch >= launch_interval:
		launch_projectile()
		time_since_launch = 0.0

# A função de atualização da trajetória agora usa a velocidade calculada
func update_trajectory():
	trajectory_line.clear_points()
	
	# Calcula a velocidade inicial necessária
	var initial_velocity = calculate_initial_velocity()

	# Se a velocidade for zero (alvo inalcançável), não desenhe a linha
	if initial_velocity == Vector2.ZERO:
		return

	var current_position = launch_point.global_position
	for i in range(trajectory_point_count):
		trajectory_line.add_point(trajectory_line.to_local(current_position))
		var t = i * 0.1
		
		# A fórmula da trajetória continua a mesma
		var next_pos_x = initial_velocity.x * t
		var next_pos_y = initial_velocity.y * t + 0.5 * gravity * t * t
		current_position = launch_point.global_position + Vector2(next_pos_x, next_pos_y)

# -----------------------------------------------------------------------------
# VERSÃO FINAL CORRIGIDA - CONSTRUÇÃO MANUAL DO VETOR
# -----------------------------------------------------------------------------
func calculate_initial_velocity() -> Vector2:
	var target_pos = target_node.global_position
	var launcher_pos = launch_point.global_position
	
	var distance_vector = target_pos - launcher_pos
	var dx = distance_vector.x
	# Usamos a convenção da física (Y para cima é positivo) para os cálculos
	var dy = -distance_vector.y
	
	var abs_dx = abs(dx)
	
	# O ângulo de lançamento para os cálculos da física
	var angle_rad = deg_to_rad(launch_angle_degrees)
	
	# A matemática para encontrar a magnitude da velocidade (v) não muda
	var cos_angle = cos(angle_rad)
	var tan_angle = tan(angle_rad)
	var denominator = 2 * cos_angle * cos_angle * (abs_dx * tan_angle - dy)
	
	if denominator <= 0:
		print("Alvo em posição impossível para este ângulo.")
		return Vector2.ZERO

	var g = gravity
	var v_squared = (g * abs_dx * abs_dx) / denominator
	var v = sqrt(v_squared)

	# --- CORREÇÃO PRINCIPAL: Construir o vetor manualmente ---

	# 1. Calcula os componentes X e Y da velocidade como na física padrão
	var vx = v * cos(angle_rad)
	var vy = v * sin(angle_rad) # vy > 0 significa "para cima"

	# 2. Monta o vetor final para o Godot
	#    - A direção X depende se o alvo está à esquerda ou à direita (sign(dx))
	#    - A direção Y precisa ser invertida, pois "para cima" em física (vy > 0)
	#      é "para baixo" no Godot (y < 0)
	var final_velocity = Vector2(sign(dx) * vx, -vy)
	
	return final_velocity


func launch_projectile():
	if not projectile_scene:
		print("Cena do projétil não definida!")
		return

	var projectile = projectile_scene.instantiate() as RigidBody2D
	get_parent().add_child(projectile)
	projectile.global_position = launch_point.global_position
	
	# Calcula a velocidade e a aplica. Agora ela será diferente a cada vez,
	# dependendo da distância do alvo.
	var initial_velocity = calculate_initial_velocity()
	if initial_velocity != Vector2.ZERO:
		projectile.linear_velocity = initial_velocity
	
	throw.emit()
