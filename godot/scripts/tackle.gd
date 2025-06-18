extends RigidBody2D

# A group to identify the secondary object (the character).
@export var target_group: String = "player"

# Multiplier for the launch force.
@export var force_multiplier: float = 2000.0

# NEW: Offset de rotação em radianos. Ajuste este valor!
# Use PI (para 180 graus), PI/2 (para 90 graus), -PI/2 (para -90 graus), etc.
# Se o seu RayCast aponta para a ESQUERDA, use PI.
# Se o seu RayCast aponta para CIMA, use -PI / 2.
# Se o seu RayCast aponta para BAIXO, use PI / 2.
@export var rotation_offset: float = PI # Exemplo para uma abelha que aponta para a esquerda

@onready var raycast: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer

var target_object = null
var is_charging: bool = false

@export var max_tackle_count = 1
var tackle_count = 0

@export var max_rotation_degrees: float = 30.0
var start_rotation: float = 0

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_charging and is_instance_valid(target_object):
		# 1. Definimos o nosso limite em radianos.
		var max_rotation_rad = deg_to_rad(max_rotation_degrees)

		# 2. Calculamos o ângulo ideal (absoluto) para olhar para o alvo.
		var angle_to_target = (target_object.global_position - global_position).angle()

		# 3. Calculamos o ângulo que o nosso sprite precisa ter para olhar para o alvo.
		#    Isso considera o offset da imagem.
		var desired_rotation = angle_to_target + rotation_offset

		# 4. Calculamos a DIFERENÇA entre a rotação desejada e a rotação INICIAL da carga.
		#    `angle_difference` lida corretamente com a "virada" de 180 para -180 graus.
		var angle_diff = angle_difference(desired_rotation, start_rotation)

		# 5. Clampamos (limitamos) essa DIFERENÇA de ângulo.
		var clamped_diff = clamp(angle_diff, -max_rotation_rad, max_rotation_rad)

		# 6. A nossa rotação final será a rotação INICIAL mais a diferença limitada.
		global_rotation = start_rotation + clamped_diff * -1

	elif not is_charging and tackle_count < max_tackle_count:
		detect_target()
	
	else:
		lock_rotation = tackle_count >= max_tackle_count

func detect_target():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group(target_group):
			is_charging = true
			target_object = collider
			start_rotation = global_rotation
			timer.start()

func _on_timer_timeout():
	if not is_instance_valid(target_object):
		is_charging = false
		target_object = null
		return

	# --- LÓGICA DE LANÇAMENTO CORRIGIDA ---
	# Agora, a "frente" da abelha é determinada pela sua rotação.
	# Vector2.RIGHT.rotated(global_rotation) nos dá o vetor que aponta para a "frente"
	# relativa da abelha, considerando a rotação que acabamos de aplicar.
	var launch_direction = Vector2.RIGHT.rotated(global_rotation - rotation_offset)
	# ---------------------------------------

	apply_central_impulse(launch_direction * force_multiplier)

	is_charging = false
	target_object = null
	tackle_count += 1
