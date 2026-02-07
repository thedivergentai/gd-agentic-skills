# skills/navigation-pathfinding/scripts/smart_navigation_agent.gd
extends NavigationAgent3D

## Smart Navigation Agent Expert Pattern
## Enhanced NavigationAgent with path smoothing and dynamic obstacle avoidance.

class_name SmartNavigationAgent

signal path_updated
signal target_unreachable
signal obstacle_detected(obstacle_position: Vector3)

@export var look_ahead_distance := 2.0
@export var obstacle_check_distance := 1.5
@export var dynamic_speed_adjustment := true

var _parent_body: CharacterBody3D
var _last_velocity := Vector3.ZERO

func _ready() -> void:
	_parent_body = get_parent() as CharacterBody3D
	if not _parent_body:
		push_error("SmartNavigationAgent must be child of CharacterBody3D")
	
	velocity_computed.connect(_on_velocity_computed)
	target_reached.connect(_on_target_reached)
	navigation_finished.connect(_on_navigation_finished)

func move_to(target_pos: Vector3) -> void:
	target_position = target_pos
	
	if is_target_reachable():
		path_updated.emit()
	else:
		target_unreachable.emit()

func update_movement(delta: float) -> Vector3:
	if not _parent_body or is_navigation_finished():
		return Vector3.ZERO
	
	var next_pos := get_next_path_position()
	var direction := (_parent_body.global_position.direction_to(next_pos) )
	
	# Dynamic speed based on proximity to target
	var speed_multiplier := 1.0
	if dynamic_speed_adjustment:
		var dist_to_target := _parent_body.global_position.distance_to(target_position)
		if dist_to_target < path_desired_distance * 3:
			speed_multiplier = clampf(dist_to_target / (path_desired_distance * 3), 0.3, 1.0)
	
	var desired_velocity := direction * max_speed * speed_multiplier
	
	# Avoidance
	if avoidance_enabled:
		set_velocity(desired_velocity)
		# Velocity is adjusted in _on_velocity_computed callback
		return _last_velocity
	else:
		return desired_velocity

func check_for_obstacles() -> bool:
	if not _parent_body:
		return false
	
	var space := _parent_body.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		_parent_body.global_position,
		_parent_body.global_position + _parent_body.basis.z * -obstacle_check_distance
	)
	query.exclude = [_parent_body]
	
	var result := space.intersect_ray(query)
	if result:
		obstacle_detected.emit(result.position)
		return true
	
	return false

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if _parent_body:
		_last_velocity = safe_velocity

func _on_target_reached() -> void:
	_last_velocity = Vector3.ZERO

func _on_navigation_finished() -> void:
	_last_velocity = Vector3.ZERO

## EXPERT USAGE:
## extends CharacterBody3D
## 
## @onready var nav: SmartNavigationAgent = $SmartNavigationAgent
## 
## func _physics_process(delta):
##     if nav.is_navigation_finished():
##         return
##     
##     velocity = nav.update_movement(delta)
##     move_and_slide()
## 
## func go_to(pos: Vector3):
##     nav.move_to(pos)
