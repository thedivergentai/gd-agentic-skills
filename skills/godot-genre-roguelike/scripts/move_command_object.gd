class_name MoveCommand extends RefCounted

## Command pattern object for turn-based movement.
## Encapsulates validation and state changes for easy Undo/Redo or logging.

var _entity: Node2D
var _target_cell: Vector2i
var _previous_cell: Vector2i
var _pathfinder: AStarGrid2D

func _init(entity: Node2D, target: Vector2i, pf: AStarGrid2D) -> void:
	_entity = entity
	_target_cell = target
	_pathfinder = pf
	# Assuming entity has a grid_position property
	if entity.get("grid_position"):
		_previous_cell = entity.grid_position

func execute() -> bool:
	# Validation: Is the cell occupied?
	if _pathfinder and _pathfinder.is_point_solid(_target_cell):
		return false
		
	# Apply state
	if _entity.has_method(&"set_grid_position"):
		_entity.call(&"set_grid_position", _target_cell)
	else:
		_entity.set(&"grid_position", _target_cell)
		
	return true

func undo() -> void:
	if _entity.has_method(&"set_grid_position"):
		_entity.call(&"set_grid_position", _previous_cell)
	else:
		_entity.set(&"grid_position", _previous_cell)
