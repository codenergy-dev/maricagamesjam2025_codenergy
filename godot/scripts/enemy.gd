extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var thrower = $Thrower
@onready var knockback = $Knockback

# Cria uma variável "proxy" que aparecerá no inspetor
@export var target_node: Node2D :
	set(value):
		target_node = value
		# Se o nó filho já estiver pronto, atualiza o valor nele diretamente
		if is_inside_tree() and thrower:
			thrower.target_node = target_node

func _ready():
	# Garante que os valores iniciais sejam aplicados quando a cena carregar
	thrower.target_node = target_node
	thrower.throw.connect(_on_throw)

func _on_throw():
	animated_sprite.play("throw")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "throw":
		animated_sprite.play("idle")

func _on_knockback_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return
	if animated_sprite.animation == "knockback":
		return
	thrower.target_node = null
	position.y += 25
	knockback.collision_layer = 128
	animated_sprite.play("knockback")
