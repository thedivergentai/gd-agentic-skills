# wave_loop_patterns.gd
extends Node

# 1. Background Scene Preloading
# EXPERT NOTE: Prevents frame-stutters when a massive wave or big boss is about to spawn.
func prepare_boss_wave(scene_path: String) -> void:
    ResourceLoader.load_threaded_request(scene_path)

# 2. Defereed Spawning for Physics Safety
# EXPERT NOTE: Ensures physics engines aren't interrupted by mid-frame instantiations.
func spawn_enemy_deferred(scene: PackedScene, spawn_pos: Vector3) -> void:
    var enemy := scene.instantiate() as Node3D
    enemy.position = spawn_pos
    # Safely adds the child at the end of the frame
    call_deferred(&"add_child", enemy)

# 3. Mass Broadcasting to Enemy Groups
# EXPERT NOTE: Instantly commands all mobs on the map to switch behavior states using StringName.
func enrage_active_enemies() -> void:
    get_tree().call_group(&"enemies", &"enter_enrage_mode")

# 4. Asynchronous Navigation Pathfinding
# EXPERT NOTE: Offloads pathfinding calculations to background threads to handle hundreds of agents.
func request_enemy_path(start: Vector3, end: Vector3, callback: Callable) -> void:
    var params := NavigationPathQueryParameters3D.new()
    params.start_position = start
    params.target_position = end
    # Assuming callback takes the result as an argument
    NavigationServer3D.query_path(params, _on_path_result.bind(callback))

func _on_path_result(result: NavigationPathQueryResult3D, callback: Callable) -> void:
    callback.call(result.path)

# 5. Bypassing Nodes for Swarms (Server-Side)
# EXPERT NOTE: Spawns physical bodies directly in the C++ physics server for extreme scale (10,000+ units).
func create_server_only_mob(xform: Transform3D) -> RID:
    var body_rid := PhysicsServer3D.body_create()
    PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_KINEMATIC)
    PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
    PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, xform)
    return body_rid

# 6. Deep Duplication of Resource Stats
# EXPERT NOTE: Ensures every spawned mob gets a unique copy of the base stats to prevent shared health pools.
@export var base_enemy_stats: Resource
func setup_individual_stats(enemy_node: Node) -> void:
    if enemy_node.has_method(&"set_stats"):
        enemy_node.set_stats(base_enemy_stats.duplicate_deep())

# 7. Optimized Enemy Counting
# EXPERT NOTE: Quickly queries the engine's group count without iterating.
func get_active_enemy_count() -> int:
    return get_tree().get_node_count_in_group(&"enemies")

# 8. Fast MultiMeshInstance Transforms
# EXPERT NOTE: Manipulates thousands of mesh transforms in a single call for minion swarms.
func batch_update_swarm_visuals(multi_mesh: MultiMesh, index: int, xform: Transform3D) -> void:
    multi_mesh.set_instance_transform(index, xform)

# 9. Proper Avoidance Masking
# EXPERT NOTE: Stops swarming enemies from walking inside each other using NavigationServer.
func setup_mob_avoidance(agent_rid: RID, layer: int) -> void:
    NavigationServer3D.agent_set_avoidance_enabled(agent_rid, true)
    NavigationServer3D.agent_set_avoidance_mask(agent_rid, layer)

# 10. Despawning with Screen Notifications
# EXPERT NOTE: Frees engine memory automatically when a wave pushes an enemy out of bounds.
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
    # Optional logic: only despawn if far enough or certain conditions met
    queue_free()
