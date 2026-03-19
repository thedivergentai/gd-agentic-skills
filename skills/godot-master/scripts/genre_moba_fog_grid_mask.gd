# fog_grid_mask.gd
extends Node2D
class_name FogGridMask

# TileMapLayer Fog of War Masking
# Efficiently clears grid cells based on unit vision radius.

@export var fog_layer: TileMapLayer

func reveal_circle(world_pos: Vector2, cell_radius: int) -> void:
    if not fog_layer: return
    
    # Convert world to local grid coordinates.
    var center_cell: Vector2i = fog_layer.local_to_map(fog_layer.to_local(world_pos))
    
    # Iterate through a square bounding box and clear within the radius.
    for x in range(-cell_radius, cell_radius + 1):
        for y in range(-cell_radius, cell_radius + 1):
            if Vector2(x, y).length() <= cell_radius:
                # -1 source_id clears the cell in Godot 4 TileMapLayer.
                fog_layer.set_cell(center_cell + Vector2i(x, y), -1)
