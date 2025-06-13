extends Node2D

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
