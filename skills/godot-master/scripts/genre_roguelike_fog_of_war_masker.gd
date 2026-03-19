class_name FogManager extends Node2D

## Grid-based Fog of War masker for TileMapLayer.
## Efficiently clears "fog" tiles based on FOV results.

@export var fog_layer: TileMapLayer
@export var fog_atlas_coord := Vector2i(0, 0) # Coordinate of the black tile in tileset
@export var fog_source_id := 0

func initialize_fog(region: Rect2i) -> void:
	if not fog_layer: return
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			fog_layer.set_cell(Vector2i(x, y), fog_source_id, fog_atlas_coord)

func reveal_cells(visible_cells: Array[Vector2i]) -> void:
	if not fog_layer: return
	for cell in visible_cells:
		# Setting source_id to -1 removes the cell (erases fog)
		fog_layer.set_cell(cell, -1)
