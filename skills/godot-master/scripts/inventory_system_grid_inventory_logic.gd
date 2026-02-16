# godot-master/scripts/inventory_system_grid_inventory_logic.gd
extends Resource
class_name GridInventory

## Grid Inventory Expert Pattern
## Implements Tetris-style cell occupancy and rotation math.

@export var grid_size: Vector2i = Vector2i(10, 8)
var _grid: Array = [] # 2D Array of item_ids or null

func _init() -> void:
    for x in grid_size.x:
        _grid.append([])
        for y in grid_size.y:
            _grid[x].append(null)

func can_place_item(item_size: Vector2i, pos: Vector2i) -> bool:
    # 1. Bounds & Occupancy Check
    if pos.x < 0 or pos.y < 0 or \
       pos.x + item_size.x > grid_size.x or \
       pos.y + item_size.y > grid_size.y:
        return false
        
    for x in range(pos.x, pos.x + item_size.x):
        for y in range(pos.y, pos.y + item_size.y):
            if _grid[x][y] != null:
                return false
    return true

func place_item(item_id: String, item_size: Vector2i, pos: Vector2i) -> void:
    if not can_place_item(item_size, pos): return
    
    for x in range(pos.x, pos.x + item_size.x):
        for y in range(pos.y, pos.y + item_size.y):
            _grid[x][y] = item_id

## EXPERT NOTE:
## For irregular shapes (L-shapes, T-shapes), use a 'BitMap' or an 
## 'Array of Vector2i' representing the relative cell offsets instead 
## of a simple 'item_size' Vector2i.
## For 'inventory-system', ALWAYS decouple the 'InventoryResource' (Data) 
## from the 'InventoryPanel' (UI). The UI should only listen to signals 
## (e.g., 'item_placed', 'item_removed') and update its visual grid accordingly.
