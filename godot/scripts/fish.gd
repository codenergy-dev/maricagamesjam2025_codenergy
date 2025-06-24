extends CharacterBody2D

@export var move_speed: float = -25.0
@export var move_frequency: float = 0.8
@export var move_amplitude: float = 35.0

# Pegamos a referência para o nosso Sprite2D filho
@onready var sprite: Sprite2D = $Sprite2D

var initial_position_y: float
var time: float = 0.0

func _ready():
	initial_position_y = global_position.y
	# Gera um tempo aleatório para que os peixes não se movam todos em sincronia
	time = randf() * PI * 2.0

func _physics_process(delta: float):
	time += delta * move_frequency
	
	# Movimento para frente constante
	# Usamos transform.x para sempre se mover na direção "local" para a direita do peixe
	velocity = transform.x * move_speed
	
	# Movimento vertical senoidal para criar um efeito de "flutuação"
	# Usamos a posição global para o cálculo, para que o peixe flutue em torno de sua linha.
	var new_y = initial_position_y + sin(time) * move_amplitude
	global_position.y = lerp(global_position.y, new_y, delta * 2.0)
	
	# move_and_slide lida com a aplicação da velocidade
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider:
			move_speed = abs(move_speed) * collision.get_normal().x
			sprite.flip_h = move_speed > 0
			break

# --- A FUNÇÃO MÁGICA ---
# Esta função será chamada pelo Spawner para configurar a aparência do peixe.
func set_sprite_texture(atlas_texture: Texture2D, region_rect: Rect2i):
	# Garante que o nó do sprite esteja pronto antes de tentarmos acessá-lo.
	await ready 
	
	if sprite:
		sprite.texture = atlas_texture
		sprite.region_enabled = true
		sprite.region_rect = region_rect
