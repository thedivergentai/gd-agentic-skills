# fast_metadata_cache.gd
# Optimizing Custom Data lookups for massive levels [22, 181]
extends TileMapLayer

# PROBLEM: get_cell_tile_data() can be slow if called thousands of times per frame.
# SOLUTION: Cache semantic metadata in a Dictionary.

var _hazard_cache: Dictionary = {} # Vector2i -> bool

func rebuild_hazard_cache() -> void:
	_hazard_cache.clear()
	for cell in get_used_cells():
		var data = get_cell_tile_data(cell)
		if data and data.get_custom_data("is_lava"):
			_hazard_cache[cell] = true

func is_cell_hazardous(map_pos: Vector2i) -> bool:
	return _hazard_cache.get(map_pos, false)
