# puzzle_pathfinder.gd
extends Node
class_name PuzzlePathfinder

# High-Performance Grid Pathfinding (AStarGrid2D)
# Specialized grid for puzzles, avoiding manual point connections.

var astar_grid := AStarGrid2D.new()

func setup_grid(grid_rect: Rect2i, cell_dimensions: Vector2) -> void:
    astar_grid.region = grid_rect
    astar_grid.cell_size = cell_dimensions
    
    # Pattern: Update is MANDATORY after modifying parameters.
    astar_grid.update()

func get_grid_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    # Returns an optimized array of Vector2i grid coordinates.
    return astar_grid.get_id_path(start, end)
