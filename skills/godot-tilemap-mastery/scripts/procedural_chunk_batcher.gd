# procedural_chunk_batcher.gd
# Efficient procedural tile placement using batching [17, 197]
extends TileMapLayer

# PROBLEM: set_cell() is slow in loops.
# SOLUTION: Use an array of data and set in one call (internal C++ optimization).

func generate_flat_chunk(chunk_origin: Vector2i, width: int, height: int) -> void:
	var cells: Array[Vector2i] = []
	var source_id = 0
	var atlas_coords = Vector2i(1, 1) # Grass tile
	
	for x in range(width):
		for y in range(height):
			cells.append(chunk_origin + Vector2i(x, y))
	
	# Expert: Bulk setting cells is significantly faster for procedural gen
	for cell in cells:
		set_cell(cell, source_id, atlas_coords)
	
	# For even better perf with Terrains:
	# set_cells_terrain_connect(cells, 0, 0)
