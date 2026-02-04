extends TileMapLayer

func _ready() -> void:
	var tile_map_cell_position = Vector2i(0,0) 
	var tile_data = get_cell_tile_data(tile_map_cell_position)
	if tile_data : 
		var tile_map_cell_source_id = get_cell_source_id(tile_map_cell_position); 
		var tile_map_cell_atlas_coords = get_cell_atlas_coords(tile_map_cell_position) 
		var tile_map_cell_alternative = get_cell_alternative_tile(tile_map_cell_position) 
		var new_tile_map_cell_position = tile_map_cell_position + Vector2i.RIGHT
		set_cell(new_tile_map_cell_position, tile_map_cell_source_id, tile_map_cell_atlas_coords, tile_map_cell_alternative)
