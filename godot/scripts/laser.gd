class_name Laser
extends Node2D # Mudei para Node2D, pois RigidBody2D não era necessário aqui. Se for, pode manter.

@export_group("Comportamento")
@export var flip: bool = false # Vira o laser horizontalmente
@export var auto: bool = true  # Dispara automaticamente
@export var cooldown: float = 1.0 # Tempo em segundos entre os disparos

@export_group("Animação")
@export var charge_timeout: float = 1.0 # Tempo de "carregamento" antes do raio

@export_group("Colisão")
@export var group: String = "hitbox"
@export var collision_mask: int = 2 # player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var beam: AnimatedSprite2D = $Beam
@onready var audio: AudioManager = $AudioManager
@onready var timer: Timer = $Timer
@onready var visible_on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

# [NOVO] Variável de estado para controlar o cooldown.
var is_ready_to_shoot: bool = true

func _ready() -> void:
	hitbox.add_to_group(group)
	hitbox.collision_mask = 1 << (collision_mask - 1)
	
	beam.visible = false
	
	# --- LÓGICA DO FLIP ---
	# Se 'flip' estiver marcado, inverte a escala horizontal do nó raiz.
	# Isso vai inverter o sprite, a área de colisão e tudo mais.
	if flip:
		scale.x *= -1
	
	# --- LÓGICA DO AUTO COM TIMER ---
	if auto:
		# Conecta o sinal 'timeout' do timer à nossa função de tiro
		timer.timeout.connect(shoot)
		# O tempo de espera do timer será o nosso cooldown
		timer.wait_time = cooldown
		# Inicia o timer
		timer.start()

# [MODIFICADO] A função 'shoot' agora é assíncrona e lida com o cooldown.
func shoot():
	# --- LÓGICA DO COOLDOWN ---
	# Se o laser não estiver pronto, a função para aqui.
	if not is_ready_to_shoot:
		return
	
	if not visible_on_screen.is_on_screen():
		return
	
	# 1. Trava o laser para impedir disparos consecutivos.
	is_ready_to_shoot = false
	
	# --- LÓGICA DE ANIMAÇÃO (sua lógica original) ---
	animation_player.play("charge")
	await get_tree().create_timer(charge_timeout).timeout
	
	animation_player.play("beam")
	audio.play("shoot")
	await animation_player.animation_finished
	
	# --- LÓGICA DO COOLDOWN (continuação) ---
	# 2. Espera o tempo de cooldown definido passar.
	await get_tree().create_timer(cooldown).timeout
	
	# 3. Libera o laser para o próximo disparo.
	is_ready_to_shoot = true
