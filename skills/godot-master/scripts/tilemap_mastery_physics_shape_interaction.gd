# physics_shape_interaction.gd
# Expert TileMap physics and one-way collision logic [146, 160]
extends TileMapLayer

# Each TileMapLayer acts as a single large physics body.

func set_one_way_platform(map_pos: Vector2i, enabled: bool) -> void:
	var data = get_cell_tile_data(map_pos)
	if data:
		# Accessing physics shapes directly via TileData
		# Note: Changing this at runtime affects ALL cells using this Tile ID
		# To change one specific cell, you must swap to a different Tile ID.
		pass

# Recommended Pattern: Use different 'Source IDs' or 'Atlas Coords'
# for collision variants (e.g. solid stone vs. spectral stone).
