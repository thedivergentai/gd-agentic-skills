# destructible_tile_logic.gd
# Runtime tile modification and destruction [278]
extends TileMapLayer

# Pattern for damaging and breaking tiles based on custom data.

func damage_tile(world_pos: Vector2, damage: float) -> void:
	var map_pos = local_to_map(to_local(world_pos))
	var data = get_cell_tile_data(map_pos)
	
	if not data: return
	
	# Custom Data Layers allow storing 'HP' or 'Hardness' on the tile itself
	var hardness = data.get_custom_data("hardness")
	if hardness > 0:
		# If the tile is broken, replace with debris or erase
		_trigger_break_fx(world_pos)
		erase_cell(map_pos)

func _trigger_break_fx(pos: Vector2) -> void:
	# Spawn particles or debris debris at the world position
	pass
