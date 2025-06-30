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
	var level: Level = get_parent()
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
					set_sprite_texture(spawn_instance, cell_coords)
					game.add_child(spawn_instance)
					level.spawn_instances.append(spawn_instance)
					set_cell(cell_coords, -1)

func set_sprite_texture(node: Node, cell_coords: Vector2):
	await node.ready
	
	var has_sprite = node.has_node("Sprite2D")
	if not has_sprite:
		return
	
	var sprite: Sprite2D = node.get_node("Sprite2D")
	if not sprite.texture:
		var source_id = get_cell_source_id(cell_coords)
		var atlas_coords = get_cell_atlas_coords(cell_coords)
		var tile_source = tile_set.get_source(source_id)
		var entity_size_in_tiles = tile_source.get_tile_size_in_atlas(atlas_coords)
		var atlas_texture: Texture2D = tile_source.texture
		var tile_size_in_pixels = tile_source.texture_region_size
		var region_size_in_pixels = entity_size_in_tiles * tile_size_in_pixels
		var region_start_in_pixels = atlas_coords * tile_size_in_pixels
		var region_rect = Rect2i(region_start_in_pixels, region_size_in_pixels)
		sprite.texture = atlas_texture
		sprite.region_enabled = true
		sprite.region_rect = region_rect
