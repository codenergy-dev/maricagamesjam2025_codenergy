extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
# Pega uma referência ao nó filho
@onready var thrower = $Thrower

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
