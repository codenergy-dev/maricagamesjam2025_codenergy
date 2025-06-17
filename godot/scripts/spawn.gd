extends TileMapLayer

# ...
# Dicionário mapeia o texto do custom data para a cena
@export var spawn_map: Dictionary[String, PackedScene] = {}

func _ready():
	await get_tree().process_frame
	spawn_enemies()

func spawn_enemies():
	# Itera sobre a sua camada de cenário principal
	var used_cells = get_used_cells()

	for cell_coords in used_cells:
		var tile_data = get_cell_tile_data(cell_coords)
		if tile_data:
			var spawn = tile_data.get_custom_data("spawn")
			if spawn_map.has(spawn):
				# 1. Pega o caminho da cena do inimigo
				var spawn_scene = spawn_map[spawn]

				if spawn_scene:
					# 2. Calcula a posição no mundo para o spawn
					var spawn_position = to_global(map_to_local(cell_coords))

					# Instancia a cena do inimigo
					var spawn_instance = spawn_scene.instantiate()
					spawn_instance.global_position = spawn_position

					# Adiciona o inimigo à cena (como irmão do TileMap, por exemplo)
					var game = get_tree().get_first_node_in_group("game")
					game.add_child(spawn_instance)

					# 3. Apaga o tile marcador para que ele não apareça no jogo
					set_cell(cell_coords, -1)
