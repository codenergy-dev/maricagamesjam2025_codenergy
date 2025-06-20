extends Node

# O caminho será um array de dicionários. Cada dicionário é um "ponto no tempo".
var player_path: Array = []

# Duração máxima do caminho a ser guardado em segundos. Ajuste conforme necessário.
# Deve ser um pouco maior que o maior delay que você pretende usar.
const MAX_PATH_DURATION = 5.0 

# Função para o jogador adicionar um novo ponto ao caminho
func record_player_state(position: Vector2, flip_h: bool, velocity_y: float):
	var current_time = Time.get_ticks_msec()
	
	player_path.append({
		"time": current_time,
		"position": position,
		"flip_h": flip_h,
		"velocity_y": velocity_y # Importante para saber se está pulando/caindo
	})
	
	# Limpa pontos antigos para não usar memória infinita
	while not player_path.is_empty() and current_time - player_path[0].time > MAX_PATH_DURATION * 1000:
		player_path.pop_front()

# Função para o follower encontrar a posição em um tempo específico no passado
func get_state_at_time(target_time: int) -> Dictionary:
	if player_path.is_empty():
		return {}

	# Procura de trás para frente (mais eficiente) pelo primeiro ponto no tempo
	# que é mais antigo que o nosso tempo alvo.
	for i in range(player_path.size() - 1, -1, -1):
		if player_path[i].time <= target_time:
			# Encontramos o "ponto de referência" no passado.
			# Para uma implementação simples, apenas retornamos este ponto.
			# (Uma versão avançada poderia interpolar entre este e o próximo ponto para suavidade extra)
			return player_path[i]
			
	# Se o tempo alvo for mais antigo que todo o nosso histórico, retorna o ponto mais antigo que temos.
	return player_path[0]

func clear_player_state():
	var last_path = player_path.slice(-4)
	player_path.clear()
	player_path = last_path
