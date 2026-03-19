# shooter_patterns.gd
extends Node

# 1. Server-Bypassing Hitscan (PhysicsDirectSpaceState3D)
# EXPERT NOTE: Direct raycasting is faster than standard ray nodes for high-frequency fire.
func fire_hitscan(origin: Vector3, direction: Vector3, shooter_rid: RID) -> void:
    var space_state := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 100)
    query.exclude = [shooter_rid]
    var result := space_state.intersect_ray(query)
    if result and result.collider.has_method(&"take_damage"):
        result.collider.call(&"take_damage", 10)

# 2. Applying Random Spread (Normal Distribution)
# EXPERT NOTE: randfn generates numbers clustered around the mean (0.0) for natural spread.
func calculate_spread(forward_vector: Vector3, spread_factor: float) -> Vector3:
    var deviation := Vector3(randfn(0.0, spread_factor), randfn(0.0, spread_factor), 0)
    return (forward_vector + deviation).normalized()

# 3. ShapeCast3D for AoE Explosions
# EXPERT NOTE: Efficient sphere casting to detect multiple targets for explosions.
func detonate_rocket(shape_rid: RID, pos: Transform3D) -> void:
    var space_state := get_world_3d().direct_space_state
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape_rid = shape_rid
    query.transform = pos
    var results := space_state.intersect_shape(query)
    for hit in results:
        if hit.collider.has_method(&"apply_impulse"):
            hit.collider.apply_impulse(Vector3.UP * 10)

# 4. Spawning Bullet Hole Decals
# EXPERT NOTE: Use RenderingServer for low-overhead decal placement.
func spawn_decal(pos: Vector3, normal: Vector3) -> void:
    var decal_rid := RenderingServer.decal_create()
    RenderingServer.instance_set_transform(decal_rid, Transform3D(Basis(), pos))
    # Additional setup: set texture, size, and world scenario

# 5. Projectile Server Instantiation (Bypassing Nodes)
# EXPERT NOTE: Create physics bodies directly in the server for bullet hell performance.
func spawn_server_bullet(transform: Transform3D) -> RID:
    var body_rid := PhysicsServer3D.body_create()
    PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_KINEMATIC)
    PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
    PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, transform)
    return body_rid

# 6. Recoil Interpolation via Tweens
# EXPERT NOTE: Procedural recoil that smoothly returns to center.
func apply_recoil(camera: Camera3D, kickback: float) -> void:
    var tween := create_tween()
    tween.tween_property(camera, "rotation:x", camera.rotation.x + kickback, 0.05)
    tween.tween_property(camera, "rotation:x", camera.rotation.x, 0.1)

# 7. AI Taking Cover (NavigationServer3D)
# EXPERT NOTE: Inform the navigation agent of its position manually for server-side AI.
func move_ai_to_cover(agent_rid: RID, cover_pos: Vector3, global_pos: Vector3) -> void:
    NavigationServer3D.agent_set_position(agent_rid, global_pos)
    # Target setting happens in background gen
    NavigationServer3D.agent_set_velocity(agent_rid, (cover_pos - global_pos).normalized() * 5.0)

# 8. Server-Authoritative Firing
# EXPERT NOTE: Clients request; server validates and executes the shot.
@rpc("any_peer", "call_local", "reliable")
func request_fire(target_vector: Vector3) -> void:
    if multiplayer.is_server():
        var sender_id := multiplayer.get_remote_sender_id()
        # Validate ammo, cooldown, and line-of-sight here
        print("Server validated shot for player: ", sender_id)

# 9. Dynamic Weapon Crosshair Binding
# EXPERT NOTE: Use unbind(1) to connect signals with extra arguments to simple UI functions.
func connect_ui_effects(weapon_node: Node, crosshair_node: Node) -> void:
    if weapon_node.has_signal(&"fired"):
        weapon_node.connect(&"fired", crosshair_node.call.bind(&"expand").unbind(1))

# 10. Low-Latency Input Buffering
# EXPERT NOTE: Flush buffered events to ensure frame-perfect reaction to reload/fire.
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"reload"):
        Input.flush_buffered_events()
        # Trigger reload logic
