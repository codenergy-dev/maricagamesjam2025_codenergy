extends RigidBody2D

# A group to identify the secondary object (the character).
@export var target_group: String = "player"

# Multiplier for the launch force.
@export var force_multiplier: float = 1000.0

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

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_charging and is_instance_valid(target_object):
		# --- LÓGICA DE ROTAÇÃO MANUAL ---
		# 1. Calcula o ângulo em radianos na direção do alvo.
		var angle_to_target = (target_object.global_position - global_position).angle()
		
		# 2. Aplica esse ângulo à rotação global do corpo, somando nosso offset de correção.
		global_rotation = angle_to_target + rotation_offset
		# --------------------------------

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
