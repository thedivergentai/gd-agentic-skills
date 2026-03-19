# stealth_patterns.gd
extends Node

# 1. Physics Server Raycasting (Nodeless LOS)
# EXPERT NOTE: Direct raycasting via the space state is drastically faster for many AI agents.
func has_line_of_sight(from: Vector3, to: Vector3, exclude: Array[RID]) -> bool:
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = exclude
    return space.intersect_ray(query).is_empty()

# 2. Vision Cone DOT Product
# EXPERT NOTE: Efficiently check if a player is within an AI's forward-facing view cone.
func target_in_cone(forward: Vector3, to_target: Vector3, threshold_dot: float) -> bool:
    return forward.dot(to_target.normalized()) > threshold_dot

# 3. Spatial Audio Routing for AI Hearing
# EXPERT NOTE: Use specific buses for "noise" sounds so AI can listen to and prioritize them.
func play_stealth_noise(player: AudioStreamPlayer3D, is_loud: bool) -> void:
    player.bus = &"AI_Audible" if is_loud else &"Default"
    player.play()

# 4. Group Alert State Broadcasting
# EXPERT NOTE: Notify all guards in range without needing direct references to each.
func broadcast_alert() -> void:
    get_tree().call_group(&"guards", &"enter_alert_mode")

# 5. Asynchronous Navigation Queries
# EXPERT NOTE: Query complex investigation paths without stalling the main thread.
func request_investigation(nav: NavigationAgent3D, target: Vector3) -> void:
    var params := NavigationPathQueryParameters3D.new()
    params.start_position = nav.global_position
    params.target_position = target
    # NavigationServer3D.query_path(...) can be used for advanced multi-pathing

# 6. Suspending Off-Screen AI Processors
# EXPERT NOTE: Use visibility notifiers to stop heavy stealth logic when the guard is off-screen.
func _on_visibility_notifier_screen_exited() -> void:
    set_physics_process(false)

# 7. Light/Shadow Masking Check
# EXPERT NOTE: Logic for detecting if a player belongs to a specific "shadow" render layer.
func is_player_in_shadow(player: VisualInstance3D, shadow_layer: int) -> bool:
    return bool(player.layers & (1 << shadow_layer))

# 8. Optimized AI State Matching (StringName)
# EXPERT NOTE: Use StringName for 2x faster hash comparisons in high-frequency AI state machines.
func process_stealth_state(state: StringName) -> void:
    match state:
        &"patrol": pass
        &"alert": pass
        &"combat": pass

# 9. ShapeCast3D for Noise Radius (Hearing)
# EXPERT NOTE: Get all entities within a physical "hearing" sphere instantly.
func get_entities_in_radius(pos: Transform3D, shape_rid: RID) -> Array:
    var space := get_world_3d().direct_space_state
    var query := PhysicsShapeQueryParameters3D.new()
    query.transform = pos
    query.shape_rid = shape_rid
    return space.intersect_shape(query)

# 10. Dynamic Avoidance Masking
# EXPERT NOTE: Enable RVO avoidance only for guards to prevent them from bumping into each other.
func setup_ai_avoidance(agent_rid: RID) -> void:
    NavigationServer3D.agent_set_avoidance_enabled(agent_rid, true)
    NavigationServer3D.agent_set_avoidance_mask(agent_rid, 1)
