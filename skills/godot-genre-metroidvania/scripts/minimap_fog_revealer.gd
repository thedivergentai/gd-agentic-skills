# minimap_fog_revealer.gd
extends Node2D
class_name MinimapFogRevealer

# Minimap Fog of War Reveal (TileMap Based)
# Efficiently clears fog cells based on player world coordinates.

@export var fog_layer: TileMapLayer

func reveal_area(player_global_pos: Vector2) -> void:
    if not fog_layer: return
    
    # Translates global world coordinates to TileMap grid coordinates (Vector2i).
    # NEVER use floating-point types for grid-logic mapping.
    var map_coords: Vector2i = fog_layer.local_to_map(fog_layer.to_local(player_global_pos))
    
    # Erases the fog tile at the player's core location.
    fog_layer.erase_cell(map_coords)
    
    # Reveal neighbors for a larger visibility radius.
    for neighbor in fog_layer.get_surrounding_cells(map_coords):
        fog_layer.erase_cell(neighbor)
