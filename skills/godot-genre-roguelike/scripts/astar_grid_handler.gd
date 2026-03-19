class_name GridPathfinder extends Node

## Specialist AStarGrid2D handler for tile-based roguelikes.
## Prefers Manhattan heuristic for 4-way grid movement.

var _grid := AStarGrid2D.new()

func setup_grid(rect: Rect2i, cell_size: Vector2i, diagonals: bool = false) -> void:
	_grid.region = rect
	_grid.cell_size = cell_size
	
	if diagonals:
		_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
		_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	else:
		_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		
	_grid.update()

func set_cell_solid(cell: Vector2i, solid: bool = true) -> void:
	if _grid.region.has_point(cell):
		_grid.set_point_solid(cell, solid)

func get_cell_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if not _grid.region.has_point(from) or not _grid.region.has_point(to):
		return []
	return _grid.get_id_path(from, to)
