extends TileMapLayer

# ...
# Dicionário mapeia o texto do custom data para a cena
@export var spawn_map: Dictionary[String, PackedScene] = {}

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	spawn()

func spawn():
	var game = get_tree().get_first_node_in_group("game")
	var player = get_tree().get_first_node_in_group("player")
	var used_cells = get_used_cells()

	for cell_coords in used_cells:
		var tile_data = get_cell_tile_data(cell_coords)
		if tile_data:
			var spawn = tile_data.get_custom_data("spawn")
			if spawn_map.has(spawn):
				var spawn_scene = spawn_map[spawn]
				if spawn_scene:
					var spawn_position = to_global(map_to_local(cell_coords))
					if spawn == "player":
						var checkpoint_scene = spawn_map["checkpoint"]
						var checkpoint_instance = checkpoint_scene.instantiate()
						checkpoint_instance.global_position = spawn_position
						game.add_child(checkpoint_instance)
					if spawn == "player" and player:
						set_cell(cell_coords, -1)
						continue
					
					var spawn_instance = spawn_scene.instantiate()
					spawn_instance.global_position = spawn_position
					game.add_child(spawn_instance)
					set_cell(cell_coords, -1)
