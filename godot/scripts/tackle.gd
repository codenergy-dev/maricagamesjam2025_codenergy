extends RigidBody2D

# A group to identify the secondary object (the character).
@export var target_group: String = "player"

# Multiplier for the launch force.
@export var force_multiplier: float = 250.0

@export var rotation_offset: float = PI 

@export var max_rotation_degrees: float = 30.0

# [NOVO] Variáveis para configurar o recuo
@export_group("Recuo (Recoil)")
@export var detection_recoil_distance: float = 12.0 # Distância em pixels do recuo
@export var detection_recoil_duration: float = 0.5 # Duração do movimento para trás
@export var detection_return_duration: float = 0.25 # Duração do movimento de volta

@onready var raycast: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@onready var audio: AudioManager = $AudioManager

var target_object = null
var is_charging: bool = false

@export var max_tackle_count = 1
var tackle_count = 0

var start_rotation: float = 0.0

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_charging and is_instance_valid(target_object):
		var max_rotation_rad = deg_to_rad(max_rotation_degrees)
		var angle_to_target = (target_object.global_position - global_position).angle()
		var desired_rotation = angle_to_target + rotation_offset
		var angle_diff = angle_difference(desired_rotation, start_rotation)
		var clamped_diff = clamp(angle_diff, -max_rotation_rad, max_rotation_rad)
		global_rotation = start_rotation + clamped_diff * -1

	elif not is_charging and tackle_count < max_tackle_count and linear_velocity.length() < 0.05:
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
			
			# [MODIFICADO] Chama a animação de recuo
			play_detection_recoil()
			
			timer.start()
			audio.play("charge")

# [NOVO] Função que cria a animação de "aviso"
func play_detection_recoil():
	var forward_direction = Vector2.RIGHT.rotated(global_rotation - rotation_offset)
	var backward_direction = -forward_direction
	
	var start_position = global_position
	var recoil_position = global_position + backward_direction * detection_recoil_distance

	var tween = create_tween().set_parallel(false) # Garante que as animações rodem em sequência
	tween.tween_property(self, "global_position", recoil_position, detection_recoil_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", start_position, detection_return_duration).set_trans(Tween.TRANS_SINE)

# [MODIFICADO] Função agora é assíncrona
func _on_timer_timeout():
	if not is_instance_valid(target_object):
		is_charging = false
		target_object = null
		return

	# Lógica de recuo antes do impulso
	var forward_direction = Vector2.RIGHT.rotated(global_rotation - rotation_offset)
	var backward_direction = -forward_direction
	var recoil_position = global_position + backward_direction * detection_recoil_distance

	var tween = create_tween()
	tween.tween_property(self, "global_position", recoil_position, detection_recoil_duration).set_trans(Tween.TRANS_QUAD)

	# Pausa a função até o recuo terminar
	await tween.finished

	# Lógica de lançamento
	apply_central_impulse(forward_direction * force_multiplier)

	is_charging = false
	target_object = null
	tackle_count += 1


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(target_group):
		audio.play("hit")
