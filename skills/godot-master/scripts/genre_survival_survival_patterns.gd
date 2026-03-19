# survival_patterns.gd
extends Node

# 1. Time-Independent Decay
# EXPERT NOTE: Multiply decay rates by delta to ensure consistent behavior across different frame rates.
func process_survival_vitals(delta: float, decay_rate: float) -> void:
    # thirst -= decay_rate * delta
    pass

# 2. Environment Lighting Tween (Day/Night)
# EXPERT NOTE: Use interpolation to smoothly transition world lighting for atmospheric immersion.
func transition_to_night(env: Environment) -> void:
    var tween := create_tween()
    tween.tween_property(env, "ambient_light_energy", 0.1, 10.0)

# 3. MultiMeshInstance for Optimized Forests/Nature
# EXPERT NOTE: Efficiently draw thousands of static assets like trees or rocks in a single call.
func populate_nature(mm: MultiMesh, transforms: Array[Transform3D]) -> void:
    for i in transforms.size():
        mm.set_instance_transform(i, transforms[i])

# 4. Deep Duplication of Item Resources
# EXPERT NOTE: Prevent shared reference bugs (e.g., all axes breaking at once) by duplicating resources upon instance.
func initialize_item_stats(base_stats: Resource) -> Resource:
    return base_stats.duplicate(true) # Deep duplicate

# 5. Asynchronous World Chunk Loading
# EXPERT NOTE: Stream persistent world data on background threads to prevent exploration hitches.
func load_world_chunk(path: String) -> void:
    ResourceLoader.load_threaded_request(path)

# 6. GridMap Snapping for Base Building
# EXPERT NOTE: Correctly align player structures to a physical world grid for building systems.
func get_snapped_pos(grid: GridMap, world_pos: Vector3) -> Vector3:
    var cell := grid.local_to_map(world_pos)
    return grid.map_to_local(cell)

# 7. ConfigFile for Persistent Player Data
# EXPERT NOTE: Ideal for saving lightweight persistent options or simple unlocked recipes.
func save_unlocked_recipes(recipes: Array[StringName]) -> void:
    var config := ConfigFile.new()
    config.set_value("Player", "unlocked", recipes)
    config.save("user://progression.cfg")

# 8. Functional Inventory Filtering
# EXPERT NOTE: Use built-in filter method for fast searching of inventory arrays.
func get_edible_items(inventory: Array) -> Array:
    return inventory.filter(func(item): return item.get(&"is_edible") == true)

# 9. Persistent Entity Save Extraction
# EXPERT NOTE: Map all "Persist" group nodes to a dictionary for simple serialization.
func collect_world_state() -> Array[Dictionary]:
    return get_tree().get_nodes_in_group(&"Persist").map(func(n): return n.call(&"save"))

# 10. Physics Body Freeing Wrapper
# EXPERT NOTE: Always use queue_free() for nodes involved in physics to avoid immediate memory corruption.
func safely_remove_entity(entity: Node) -> void:
    if entity is Node:
        entity.queue_free()
