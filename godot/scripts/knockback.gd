extends Node

## A força a ser aplicada no knockback.
@export var force = 250.0
## A rapidez com que o efeito de knockback se dissipa. Valores mais altos = dissipação mais rápida.
@export var decay_rate = 2000.0
## Quanto menor este valor, mais fraco será o empurrão PARA CIMA. 1.0 = sem mudança.
@export var vertical_dampening = 0.6

# O vetor de knockback atual. O script do Player irá ler este valor.
var knockback = Vector2.ZERO

func _physics_process(delta):
	# Reduz o knockback ao longo do tempo até chegar a zero.
	# Esta é a única responsabilidade deste script no loop de física.
	knockback = knockback.move_toward(Vector2.ZERO, decay_rate * delta)

# Esta é uma função pública que o Player (ou qualquer outra coisa) pode chamar
# para iniciar o efeito de knockback.
func apply_knockback(direction: Vector2):
	"""
	Aplica uma força de knockback na direção fornecida,
	com o empurrão vertical amortecido.
	"""
	var modified_direction = direction

	# Se o componente Y da direção é negativo, o empurrão é para cima.
	if modified_direction.y < 0:
		# Multiplicamos APENAS o componente Y pelo nosso fator de amortecimento.
		modified_direction.y *= vertical_dampening

	# Usamos a direção modificada para calcular o knockback.
	# O vetor já não está normalizado, mas isso é bom, pois o resultado
	# é um empurrão vertical mais fraco, como queríamos.
	knockback = modified_direction * force

func is_zero():
	return knockback == Vector2.ZERO
