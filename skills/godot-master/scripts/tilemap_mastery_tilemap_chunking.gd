# godot-master/scripts/tilemap_mastery_tilemap_chunking.gd
extends Node

## TileMap Chunking Expert Pattern
## Batched terrain updates with chunk-based culling for large procedural worlds.

class_name TileMapChunking

signal chunk_generated(chunk_pos: Vector2i)

@export var tilemap_layer: TileMapLayer
@export var chunk_size := Vector2i(16, 16)
@export var view_distance := 2  # chunks

var _active_chunks := {}
var _chunk_queue := []

func _ready() -> void:
	if not tilemap_layer:
		push_error("TileMapChunking: tilemap_layer not assigned!")

func update_chunks_around(world_pos: Vector2) -> void:
	var center_chunk := world_to_chunk(world_pos)
	var required_chunks := _get_required_chunks(center_chunk)
	
	# Unload distant chunks
	var to_remove := []
	for chunk_pos in _active_chunks:
		if chunk_pos not in required_chunks:
			to_remove.append(chunk_pos)
	
	for chunk_pos in to_remove:
		_unload_chunk(chunk_pos)
	
	# Load new chunks
	for chunk_pos in required_chunks:
		if chunk_pos not in _active_chunks:
			_load_chunk(chunk_pos)

func set_chunk_terrain(chunk_pos: Vector2i, terrain_set: int, terrain: int, cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return
	
	# Batch terrain placement
	var source_id := 0
	tilemap_layer.set_cells_terrain_connect(cells, terrain_set, terrain, false)
	
	_mark_chunk_dirty(chunk_pos)

func set_chunk_cells(chunk_pos: Vector2i, cells: Dictionary) -> void:
	# cells = {Vector2i: {source_id, atlas_coords, alternative_tile}}
	if cells.is_empty():
		return
	
	var positions: Array[Vector2i] = []
	var source_ids: Array[int] = []
	var atlas_coords: Array[Vector2i] = []
	var alternatives: Array[int] = []
	
	for pos in cells:
		var data: Dictionary = cells[pos]
		positions.append(pos)
		source_ids.append(data.get("source_id", 0))
		atlas_coords.append(data.get("atlas_coords", Vector2i.ZERO))
		alternatives.append(data.get("alternative_tile", 0))
	
	# Batched set_cell
	for i in positions.size():
		tilemap_layer.set_cell(positions[i], source_ids[i], atlas_coords[i], alternatives[i])
	
	_mark_chunk_dirty(chunk_pos)

func world_to_chunk(world_pos: Vector2) -> Vector2i:
	var tile_pos := tilemap_layer.local_to_map(world_pos)
	return Vector2i(
		floori(float(tile_pos.x) / chunk_size.x),
		floori(float(tile_pos.y) / chunk_size.y)
	)

func _get_required_chunks(center: Vector2i) -> Array[Vector2i]:
	var chunks: Array[Vector2i] = []
	for x in range(-view_distance, view_distance + 1):
		for y in range(-view_distance, view_distance + 1):
			chunks.append(center + Vector2i(x, y))
	return chunks

func _load_chunk(chunk_pos: Vector2i) -> void:
	_active_chunks[chunk_pos] = true
	chunk_generated.emit(chunk_pos)

func _unload_chunk(chunk_pos: Vector2i) -> void:
	# Clear tiles in chunk
	var start := chunk_pos * chunk_size
	var cells_to_erase: Array[Vector2i] = []
	
	for x in chunk_size.x:
		for y in chunk_size.y:
			cells_to_erase.append(start + Vector2i(x, y))
	
	tilemap_layer.set_cells_terrain_connect(cells_to_erase, 0, -1, false)
	_active_chunks.erase(chunk_pos)

func _mark_chunk_dirty(chunk_pos: Vector2i) -> void:
	# Force physics/navigation update
	tilemap_layer.notify_runtime_tile_data_update()

## EXPERT USAGE:
## var chunking := TileMapChunking.new()
## chunking.tilemap_layer = $TileMapLayer
## chunking.chunk_generated.connect(_on_chunk_generated)
## 
## func _process(_delta):
##     chunking.update_chunks_around(player.global_position)
