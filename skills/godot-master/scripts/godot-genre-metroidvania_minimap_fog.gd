# skills/genre-metroidvania/scripts/minimap_fog.gd
extends Node2D

## Minimap Fog Expert Pattern
## Grid-based fog of war that saves visited chunks/rooms.

class_name MinimapFog

@export var tile_map: TileMapLayer # The minimap visual layer
@export var target: Node2D # Player to track
@export var reveal_radius: int = 1 # Tiles around player
@export var hidden_tile_id: int = 0 # Tile index for 'fog'
@export var revealed_tile_id: int = -1 # Tile index for 'empty/revealed'

# State
var _visited_cells: Dictionary = {}

func _ready() -> void:
    if not tile_map or not target:
        set_process(false)
        return

func _process(_delta: float) -> void:
    var player_cell = tile_map.local_to_map(target.global_position)
    
    # Reveal circular area
    for x in range(-reveal_radius, reveal_radius + 1):
        for y in range(-reveal_radius, reveal_radius + 1):
            if Vector2(x, y).length() <= reveal_radius:
                var cell = player_cell + Vector2i(x, y)
                reveal_cell(cell)

func reveal_cell(cell: Vector2i) -> void:
    if cell in _visited_cells:
        return
        
    # Mark visited
    _visited_cells[cell] = true
    
    # Update Visuals
    # Option A: Clear 'Fog' tile
    if revealed_tile_id == -1:
        tile_map.erase_cell(cell)
    # Option B: Set 'Revealed' tile
    else:
        tile_map.set_cell(cell, revealed_tile_id, Vector2i.ZERO)

func get_save_data() -> Dictionary:
    # Convert Vector2i keys to String for JSON serialization
    var save_dict = {}
    for cell in _visited_cells:
        save_dict["%d,%d" % [cell.x, cell.y]] = true
    return save_dict

func load_save_data(data: Dictionary) -> void:
    _visited_cells.clear()
    for key in data:
        var parts = key.split(",")
        var cell = Vector2i(int(parts[0]), int(parts[1]))
        reveal_cell(cell)

## EXPERT USAGE:
## Assign a TileMapLayer used as an overlay. Fill it with 'Fog' tiles.
## As player moves, fog is erased/replaced.
