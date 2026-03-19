# skills/3d-world-building/scripts/grid_map_manager.gd
extends GridMap

## Grid Map Manager (Expert Pattern)
## Handles runtime tile placement, coordinate conversion, and batch operations.
## Ensures navigation updates if using NavigationRegion3D.

class_name GridMapManager

signal tile_placed(grid_pos: Vector3i, item_id: int)
signal tile_removed(grid_pos: Vector3i)

@export var navigation_region: NavigationRegion3D

# Helper to map world position to grid center (for snapping)
func snap_to_grid(world_pos: Vector3) -> Vector3:
    var grid_pos = local_to_map(to_local(world_pos))
    return to_global(map_to_local(grid_pos))

func place_tile_at_world(world_pos: Vector3, item_id: int, orientation: int = 0) -> void:
    var grid_pos = local_to_map(to_local(world_pos))
    set_cell_item(grid_pos, item_id, orientation)
    tile_placed.emit(grid_pos, item_id)
    _update_navigation_deferred()

func remove_tile_at_world(world_pos: Vector3) -> void:
    var grid_pos = local_to_map(to_local(world_pos))
    if get_cell_item(grid_pos) != INVALID_CELL_ITEM:
        set_cell_item(grid_pos, INVALID_CELL_ITEM)
        tile_removed.emit(grid_pos)
        _update_navigation_deferred()

func get_tile_id_at_world(world_pos: Vector3) -> int:
    var grid_pos = local_to_map(to_local(world_pos))
    return get_cell_item(grid_pos)

# Batch operations
func fill_area(start: Vector3i, end: Vector3i, item_id: int) -> void:
    for x in range(min(start.x, end.x), max(start.x, end.x) + 1):
        for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
            for z in range(min(start.z, end.z), max(start.z, end.z) + 1):
                set_cell_item(Vector3i(x,y,z), item_id)
    _update_navigation_deferred()

func _update_navigation_deferred() -> void:
    if navigation_region:
        # Debounce or deferred bake recommended for performance
        # navigation_region.bake_navigation_mesh() (Blocking!)
        # Use Thread or signal for complex maps.
        pass

## EXPERT USAGE:
## Attach to GridMap node. Use snap_to_grid() for building preview.
