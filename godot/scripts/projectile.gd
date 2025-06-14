# Projectile.gd
extends RigidBody2D

# Exporte estas variáveis para poder ajustá-las facilmente no Inspetor.
@export var max_bounces = 2 # O número de vezes que o projétil pode quicar.
@export var bounce_dampening = 0.6 # Fator de quique. 1.0 = quique perfeito, 0.5 = perde 50% da força.

# Variável interna para contar os quiques.
var current_bounces = 0

func _ready():
	# Conecta o sinal 'body_entered' a uma função para detectar colisões.
	# Isso nos permite verificar com o que o projétil colidiu.
	self.body_entered.connect(_on_body_entered)

	# Cria e aplica um PhysicsMaterial dinamicamente.
	# Isso nos dá controle sobre as propriedades físicas, como o quique.
	var material = PhysicsMaterial.new()
	material.bounce = bounce_dampening
	self.physics_material_override = material


func _on_body_entered(body):
	if body.is_in_group("player"):
		# AQUI ESTÁ A LÓGICA PRINCIPAL
		# Nós removemos a camada do 'player' da nossa máscara de colisão.
		# A camada do player é a número 2. O valor dela em bits é 2.
		# A operação "& ~" significa "desligue o bit correspondente".
		collision_mask &= ~2
		collision_layer = 128
	# Verifica se o corpo com o qual colidimos está no grupo "ground".
	if body.is_in_group("ground"):
		
		# Verifica se ainda temos quiques restantes.
		if current_bounces < max_bounces:
			current_bounces += 1
			print("Quicou! (", current_bounces, "/", max_bounces, ")")
			
			# Opcional: Você pode adicionar um efeito sonoro ou de partícula aqui.
			
		else:
			# Se não houver mais quiques, removemos a capacidade de quicar.
			# Ao definir o 'bounce' como 0, o projétil vai parar de quicar
			# e deslizará até parar na próxima colisão com o chão.
			if physics_material_override:
				print("Sem mais quiques. O projétil vai parar.")
				physics_material_override.bounce = 0
