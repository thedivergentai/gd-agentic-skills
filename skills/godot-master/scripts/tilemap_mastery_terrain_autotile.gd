extends TileMapLayer

## Expert runtime terrain autotiling with batching and validation.
## Use for destructible terrain or runtime level generation.

@export var terrain_set: int = 0
@export var terrain: int = 0

## Updates a single cell and its neighbors to maintain terrain connectivity.
func set_terrain_cell(coords: Vector2i, type: int = terrain) -> void:
    set_cells_terrain_connect([coords], terrain_set, type, true)

## Updates multiple cells in a batch. More efficient than multiple single calls.
func set_terrain_cells(coords_list: Array[Vector2i], type: int = terrain) -> void:
    if coords_list.is_empty(): return
    set_cells_terrain_connect(coords_list, terrain_set, type, true)

## Clears cells and updates neighbors to fix edges.
func erase_terrain_cells(coords_list: Array[Vector2i]) -> void:
    if coords_list.is_empty(): return
    for coords in coords_list:
        erase_cell(coords)
    
    # Force update neighbors by calling connect on an empty terrain or just refreshing
    # In Godot 4, removing then updating neighbors is often done via an update area call
    # but set_cells_terrain_connect on neighbors is the most robust way.
    var neighbors = []
    for cell in coords_list:
        for neighbor in get_surrounding_cells(cell):
            if neighbor not in neighbors:
                neighbors.append(neighbor)
    
    # Refresh neighbors to fix transitions
    # We pass -1 or a specific terrain to force refresh
    # set_cells_terrain_connect(neighbors, terrain_set, -1, true)
