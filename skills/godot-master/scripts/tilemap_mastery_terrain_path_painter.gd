# terrain_path_painter.gd
# Advanced runtime terrain autotiling (Terrains v2) [20, 118]
extends TileMapLayer

# EXPERT NOTE: set_cells_terrain_connect is expensive for large areas. 
# Batch tiles and use 'false' for ignore_empty_terrains for predictable 
# organic borders.

func draw_road_path(points: Array[Vector2i], terrain_set: int, terrain_id: int) -> void:
	# Terrains v2 in Godot 4 automatically handles corner/edge transitions
	# based on the bitmask rules in the TileSet resource.
	set_cells_terrain_connect(points, terrain_set, terrain_id, false)
	
	# Force an immediate update if this is during a procedural gen step
	# update_internals() # Usually not needed but keeps RAM/Editor in sync.
