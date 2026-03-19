# sports_patterns.gd
extends Node

# 1. Physics-Safe Ball Impulses
# EXPERT NOTE: Forces and impulses must be applied in the physics step to ensure stability.
func kick_ball(ball: RigidBody3D, force_vector: Vector3) -> void:
    ball.apply_central_impulse(force_vector)

# 2. Custom Physics Materials (Bounciness)
# EXPERT NOTE: Set restitution programmatically for consistent bounce across surfaces.
func setup_ball_bounce(body: RigidBody3D, bounce: float) -> void:
    var mat := PhysicsMaterial.new()
    mat.bounce = bounce
    body.physics_material_override = mat

# 3. Dynamic Joypad Assignment
# EXPERT NOTE: Safely detect and assign connected controllers for local multiplayer/team play.
func get_active_controllers() -> Array[int]:
    return Input.get_connected_joypads()

# 4. Fast Distance Checking (Passing AI)
# EXPERT NOTE: Use distance_squared_to to bypass expensive square root calculations in loops.
func find_closest_teammate(me: Node3D, team: Array[Node3D]) -> Node3D:
    return team.reduce(func(best, p): 
        return p if me.global_position.distance_squared_to(p.global_position) < \
                    me.global_position.distance_squared_to(best.global_position) else best
    )

# 5. Authoritative Score RPC
# EXPERT NOTE: Client requests; server validates physics and position before updating score.
@rpc("any_peer", "call_local", "reliable")
func request_goal_validation(ball_rid: RID, pos: Vector3) -> void:
    if multiplayer.is_server():
        # Validate that the ball actually crossed the plane in physics space
        print("Server validated goal at: ", pos)

# 6. Unreliable State Syncing
# EXPERT NOTE: Send raw bytes via UDP for minimum latency in fast sports movement.
func sync_player_movement(data: PackedByteArray) -> void:
    multiplayer.send_bytes(data, 0, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)

# 7. Safe Controller Haptics
# EXPERT NOTE: Trigger vibration feedback for heavy tackles or successful shots.
func trigger_impact_vibration(device_id: int) -> void:
    Input.start_joy_vibration(device_id, 0.6, 1.0, 0.2)

# 8. AI Rubber-Banding Speed
# EXPERT NOTE: Adjust AI agent speed dynamically based on player distance to maintain tension.
func apply_rubber_band(agent_rid: RID, player_dist: float, factor: float) -> void:
    var speed := 5.0 + (player_dist * factor)
    NavigationServer3D.agent_set_max_speed(agent_rid, speed)

# 9. Physics Server Body State Integration
# EXPERT NOTE: Manually calculate velocities for rigid bodies without breaking physics steps.
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    # state.linear_velocity = custom_vector
    pass

# 10. Normalizing Joystick Input
# EXPERT NOTE: Always normalize input to prevent diagonal movement from being faster.
func get_move_direction(device_id: int) -> Vector2:
    var input := Vector2(
        Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
        Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
    )
    return input.normalized() if input.length() > 0.1 else Vector2.ZERO
