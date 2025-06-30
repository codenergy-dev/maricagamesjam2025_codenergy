# SmoothCamera2D.gd
extends Camera2D

# --- VARIÁVEIS DE CONFIGURAÇÃO (Ajuste no Inspetor) ---

# Alvo da câmera (o jogador)
@export var target_node: Node2D

# Suavização (Lerp)
@export_group("Suavização (Follow)")
@export var follow_smoothing_enabled: bool = true
@export var follow_speed: float = 5.0 # Quão rápido a câmera segue. Valores maiores = mais rápido.

# Offset "Olhar à Frente"
@export_group("Offset (Look Ahead)")
@export var lookahead_enabled: bool = true
@export var lookahead_offset: Vector2 = Vector2(31.25, 0) # Quão à frente/acima a câmera olha.
@export var lookahead_speed: float = 4.0 # Quão rápido o offset se ajusta.

# Zona Morta Vertical
@export_group("Zona Morta (Dead Zone)")
@export var vertical_deadzone_enabled: bool = true
@export var vertical_deadzone_height: float = 25.0 # Altura da "caixa" onde a câmera não se move.

# Limites do Mapa (Bounds)
@export_group("Limites (Bounds)")
@export var limit_top_left: Marker2D
@export var limit_bottom_right: Marker2D

# --- VARIÁVEIS INTERNAS ---
var current_lookahead_direction: float = 1.0

func _physics_process(delta: float) -> void:
	# Se o alvo não foi definido no inspetor, tenta encontrar o jogador pelo grupo.
	if not is_instance_valid(target_node):
		target_node = get_tree().get_first_node_in_group("player")
		if is_instance_valid(target_node):
			global_position.y = target_node.global_position.y
	
	# Configura os limites da câmera usando os marcadores
	if is_instance_valid(limit_top_left) and is_instance_valid(limit_bottom_right):
		limit_left = limit_top_left.global_position.x
		limit_top = limit_top_left.global_position.y
		limit_right = limit_bottom_right.global_position.x
		limit_bottom = limit_bottom_right.global_position.y

	# Se não houver alvo, não faz nada.
	if not is_instance_valid(target_node):
		return

	# --- CÁLCULO DA POSIÇÃO ALVO IDEAL ---
	# Esta é a posição perfeita onde a câmera QUER estar, sem considerar a zona morta.
	var ideal_target_pos = Vector2.ZERO
	
	# 1. CÁLCULO DO OFFSET "OLHAR À FRENTE" (EIXO X)
	if lookahead_enabled:
		var player_direction = 1.0 if target_node.get_node("AnimatedSprite2D").flip_h else -1.0
		current_lookahead_direction = lerp(current_lookahead_direction, player_direction, lookahead_speed * delta)
		ideal_target_pos.x = target_node.global_position.x + (lookahead_offset.x * current_lookahead_direction)
	else:
		ideal_target_pos.x = target_node.global_position.x
		
	# 2. CÁLCULO DA POSIÇÃO Y IDEAL
	# Incluímos o offset vertical aqui para que o jogador não fique no centro exato.
	ideal_target_pos.y = target_node.global_position.y + lookahead_offset.y


	# --- APLICAÇÃO DA ZONA MORTA E POSIÇÃO FINAL ---
	# Começamos com a posição alvo sendo a posição atual da câmera, para que ela fique parada por padrão.
	var final_target_position = global_position
	
	# Atualiza a posição X do alvo final (o eixo X não tem zona morta neste exemplo)
	final_target_position.x = ideal_target_pos.x
	
	# 3. LÓGICA DA ZONA MORTA VERTICAL CORRIGIDA
	if vertical_deadzone_enabled:
		var diff_y = ideal_target_pos.y - global_position.y
		
		# Se a câmera está fora da zona morta em relação à posição ideal...
		if abs(diff_y) > vertical_deadzone_height / 2:
			# ... então o alvo Y da câmera é a posição ideal, mas "puxada de volta"
			# pela metade da altura da zona morta. Isso faz a câmera seguir o limite da caixa.
			final_target_position.y = ideal_target_pos.y - (sign(diff_y) * vertical_deadzone_height / 2)
	else:
		# Se a zona morta estiver desativada, o alvo Y é simplesmente a posição ideal.
		final_target_position.y = ideal_target_pos.y


	# --- SUAVIZAÇÃO (LERP) ---
	# Move a câmera suavemente em direção à posição alvo final calculada.
	if follow_smoothing_enabled:
		global_position = global_position.lerp(final_target_position, follow_speed * delta)
	else:
		global_position = final_target_position

	# Os limites (bounds) são aplicados automaticamente pelo nó Camera2D.
	# Não precisamos de código extra para isso!
