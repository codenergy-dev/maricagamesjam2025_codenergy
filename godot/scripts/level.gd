extends TileMap

@export var enemy_layer: TileMapLayer

# ...
# Dicionário mapeia o texto do custom data para a cena
var enemy_map = {
	"bald": "res://scenes/enemy.tscn",
	"bee": "res://scenes/bee.tscn"
}

func _ready():
	await get_tree().process_frame
	spawn_enemies()

func spawn_enemies():
	# Itera sobre a sua camada de cenário principal
	var used_cells = enemy_layer.get_used_cells()

	for cell_coords in used_cells:
		var tile_data = enemy_layer.get_cell_tile_data(cell_coords)
		if tile_data:
			var enemy = tile_data.get_custom_data("enemy")
			if enemy_map.has(enemy):
				# 1. Pega o caminho da cena do inimigo
				var enemy_scene_path = enemy_map[enemy]
				var enemy_scene = load(enemy_scene_path)

				if enemy_scene:
					# 2. Calcula a posição no mundo para o spawn
					var spawn_position = enemy_layer.map_to_local(cell_coords)

					# Instancia a cena do inimigo
					var enemy_instance = enemy_scene.instantiate()
					enemy_instance.global_position = enemy_layer.to_global(spawn_position)

					# Adiciona o inimigo à cena (como irmão do TileMap, por exemplo)
					var game = get_tree().get_first_node_in_group("game")
					game.add_child(enemy_instance)

					# 3. Apaga o tile marcador para que ele não apareça no jogo
					enemy_layer.set_cell(cell_coords, -1)
