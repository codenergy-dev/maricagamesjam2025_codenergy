class_name Tackle
extends RigidBody2D

@export_group("Tackle")
@export var target_group: String = "player"
@export var force_multiplier: float = 250.0
@export var rotation_offset: float = PI 
@export var max_rotation_degrees: float = 30.0
@export var max_tackle_count = 1
@export var linear_velocity_threshold = 0.05
@export var animation_enabled = true

# [NOVO] Variáveis para configurar o recuo
@export_group("Tackle Recoil")
@export var detection_recoil_distance: float = 12.0 # Distância em pixels do recuo
@export var detection_recoil_duration: float = 0.5 # Duração do movimento para trás
@export var detection_return_duration: float = 0.25 # Duração do movimento de volta

@export_group("Tackle Return")
@export var return_to_start_pos: bool = false
@export var return_speed_multiplier: float = 1.0

@onready var raycast: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@onready var audio: AudioManager = $AudioManager
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var target_object = null
var is_charging: bool = false
var tackle_count = 0
var start_rotation: float = 0.0
var start_position: Vector2
var is_returning: bool = false

func _ready():
	start_position = global_position
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_charging and is_instance_valid(target_object):
		var max_rotation_rad = deg_to_rad(max_rotation_degrees)
		var angle_to_target = (target_object.global_position - global_position).angle()
		var desired_rotation = angle_to_target + rotation_offset
		var angle_diff = angle_difference(desired_rotation, start_rotation)
		var clamped_diff = clamp(angle_diff, -max_rotation_rad, max_rotation_rad)
		global_rotation = start_rotation + clamped_diff * -1

	elif not is_charging and not is_returning:
		if tackle_count < max_tackle_count:
			if linear_velocity.length() < linear_velocity_threshold:
				if return_to_start_pos and global_position.distance_to(start_position) > 5.0:
					_return_to_start_position()
				else:
					detect_target()
		else:
			lock_rotation = true

func detect_target():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if is_instance_valid(collider) and collider.is_in_group(target_group):
			is_charging = true
			target_object = collider
			start_rotation = global_rotation
			
			# [MODIFICADO] Chama a animação de recuo
			play_detection_recoil()
			
			timer.start()
			audio.play("charge")
			
			if animation_enabled and is_instance_valid(animated_sprite):
				animated_sprite.play("tackle")
	elif animation_enabled and is_instance_valid(animated_sprite):
		animated_sprite.play("default")

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

func _return_to_start_position():
	is_returning = true
	
	var distance = global_position.distance_to(start_position)
	var duration = (distance / 300.0) / return_speed_multiplier # 300 é uma velocidade base, ajuste se necessário
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_position, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	is_returning = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(target_group):
		audio.play("hit")
