# tile_pattern_stamper.gd
# Using TileMapPatterns for complex, multi-tile stamps
extends TileMapLayer

# Patterns allow you to copy/paste chunks of tiles efficiently.

func stamp_house(origin: Vector2i, pattern: TileMapPattern) -> void:
	# Patterns preserve Source IDs, Atlas Coords, and Alternative IDs
	set_pattern(origin, pattern)

func copy_area_to_pattern(rect: Rect2i) -> TileMapPattern:
	# Captures a region for later use (e.g., custom level editor)
	return get_pattern(get_used_cells_by_id().filter(func(c): return rect.has_point(c)))
