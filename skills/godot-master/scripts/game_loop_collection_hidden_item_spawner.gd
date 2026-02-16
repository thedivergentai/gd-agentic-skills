class_name HiddenItemSpawner
extends Node3D

## Automates the placement of collectible items in a level.
## Useful for "100 Eggs" hunts where manual placement is tedious.

# The item scene to spawn (must be a CollectibleItem or similar)
@export var item_scene: PackedScene

# List of Marker3D nodes to use as spawn points.
# If empty, random spawning inside collision volume loop logic would require specific shape data.
@export var spawn_points: Array[Node3D] = []

# Chance (0.0 to 1.0) to spawn an item at each point.
@export_range(0.0, 1.0) var spawn_chance: float = 0.5

# Total limit of items to spawn. 0 = No limit.
@export var max_spawn_count: int = 0

func _ready() -> void:
	spawn_items()

func spawn_items() -> void:
	if not item_scene:
		push_warning("HiddenItemSpawner: No item_scene assigned.")
		return
		
	var available_points = spawn_points.duplicate()
	
	# If no manual points, try to find collision shapes to use as volumes
	if available_points.is_empty():
		for child in get_children():
			if child is CollisionShape3D:
				available_points.append(child)

	if available_points.is_empty():
		push_warning("HiddenItemSpawner: No spawn points or collision shapes found!")
		return
		
	available_points.shuffle()
	
	var spawned_count = 0
	for point_node in available_points:
		if max_spawn_count > 0 and spawned_count >= max_spawn_count:
			break
			
		if randf() > spawn_chance:
			continue
			
		# Determine position
		var pos = point_node.global_position
		if point_node is CollisionShape3D:
			pos = _get_random_point_in_shape(point_node)
			
		_spawn_at(pos)
		spawned_count += 1

func _get_random_point_in_shape(shape_node: CollisionShape3D) -> Vector3:
	var shape = shape_node.shape
	if not shape:
		return shape_node.global_position
		
	var local_point = Vector3.ZERO
	
	if shape is BoxShape3D:
		var s = shape.size
		local_point = Vector3(
			randf_range(-s.x / 2.0, s.x / 2.0),
			randf_range(-s.y / 2.0, s.y / 2.0),
			randf_range(-s.z / 2.0, s.z / 2.0)
		)
	elif shape is SphereShape3D:
		# Random point inside sphere (volume)
		var r = shape.radius * pow(randf(), 1.0/3.0)
		local_point = Vector3.random_on_unit_sphere() * r
		
	return shape_node.to_global(local_point)

func _spawn_at(pos: Vector3) -> void:
	var item = item_scene.instantiate()
	add_child(item)
	item.global_position = pos
