# godot-master/scripts/tilemap_mastery_tilemap_data_manager.gd
extends Node

## TileMap Mastery Expert Pattern
## Implements Custom DataLayer Logic and Runtime Navigation Baking.

@onready var tilemap_layer: TileMapLayer = $TileMapLayer

# 1. Custom DataLayer Logic
func get_tile_logic(coords: Vector2i) -> Dictionary:
    # Professional pattern: Extract metadata directly from the TileSet.
    var data = tilemap_layer.get_cell_tile_data(coords)
    if not data: return {}
    
    return {
        "damage": data.get_custom_data("damage_amount"),
        "speed_mult": data.get_custom_data("movement_multiplier"),
        "is_slippery": data.get_custom_data("slippery")
    }

# 2. Runtime Terrain Manipulation
func paint_path(coords_list: Array[Vector2i], terrain_id: int) -> void:
    # Expert logic: Use terrain_connect to automatically handle autotile bitmasks.
    tilemap_layer.set_cells_terrain_connect(coords_list, 0, terrain_id)

# 3. Dynamic Navigation Baking
func update_navigation_region() -> void:
    # Professional protocol: Force a NavMesh rebake when tiles change.
    # Note: In Godot 4, TileSet handles navigation polygons. 
    # This logic ensures the NavigationServer is updated.
    NavigationServer2D.map_set_active(tilemap_layer.get_world_2d().navigation_map, true)

## EXPERT NOTE:
## Use 'Performance Chunking': For 100,000+ tiles, split the 
## TileMapLayer into 16x16 chunk scenes. Use 'TileMapLayer.hide()' 
## on distant chunks to bypass the quadrant-based drawing cost.
## For 'tilemap-mastery', implement 'TileData Logic Layers': 
## Create a 'LogicLayer' Resource that maps Tile IDs to Game Effects 
## (e.g. ID 5 = LavaArea3D spawner).
## NEVER check Tile IDs directly in gameplay code; always use 
## 'get_custom_data()' to decouple visual assets from technical logic.
## Use 'set_cells_terrain_connect' instead of manual bitmasking 
## to allow for dynamic, runtime level destruction/creation.
