# building_grid_astar.gd
extends Node
class_name BuildingGridAStar

# Grid-Based AStar for Base Building
# Instant grid pathfinding for placing structures and unit grid-navigation.

var astar_grid := AStarGrid2D.new()

func init_grid(size: Vector2i, cell_size: Vector2) -> void:
    astar_grid.region = Rect2i(Vector2i.ZERO, size)
    astar_grid.cell_size = cell_size
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar_grid.update()

func mark_occupied(cell: Vector2i, occupied: bool) -> void:
    # Pattern: AStarGrid2D is much faster than Node-based AStar for grid RTS.
    astar_grid.set_point_solid(cell, occupied)

func is_cell_valid(cell: Vector2i) -> bool:
    return not astar_grid.is_point_solid(cell)
