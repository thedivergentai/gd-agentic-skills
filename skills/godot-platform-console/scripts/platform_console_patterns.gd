# platform_console_patterns.gd
extends Node

# 1. Dynamically Polling Active Controllers
# EXPERT NOTE: Joypad 0 is not always Player 1. Always query active connections.
func get_active_players() -> Array[int]:
    return Input.get_connected_joypads()

# 2. Extracting Analog Stick Vectors with Deadzones
# EXPERT NOTE: Accounts for hardware drift automatically across multiple axis.
func get_movement_vector() -> Vector2:
    return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

# 3. Applying Controller Haptics
# EXPERT NOTE: Finite duration prevents motor burnout and respects hardware limits.
func trigger_damage_feedback(device_id: int) -> void:
    # device_id, weak_motor, strong_motor, duration_sec
    Input.start_joy_vibration(device_id, 0.5, 1.0, 0.2)

# 4. Looking up Controller GUIDs for Profiling
# EXPERT NOTE: Use for hardware-specific mapping adjustments (SDL2 compatible).
func get_gamepad_profile(device_id: int) -> String:
    return Input.get_joy_guid(device_id)

# 5. programmatic UI Focus for Gamepads
# EXPERT NOTE: Essential for console UI accessibility.
func grab_initial_menu_focus(container: Control) -> void:
    var first_btn := container.get_child(0) as Control
    if first_btn:
        first_btn.grab_focus()

# 6. Adjusting 3D Resolution Scaling (FSR)
# EXPERT NOTE: Maintain 60 FPS on lower-tier console hardware.
func enable_performance_scaling(viewport: Viewport) -> void:
    viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
    viewport.scaling_3d_scale = 0.75 # Sub-native render, upscale with FSR

# 7. Exact Input Matching
# EXPERT NOTE: Prevents overlapping action triggers in complex mappings.
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"jump", false, true): # Exact match
        print("Jump executed!")

# 8. Setting up Dynamic UI Neighbors
# EXPERT NOTE: Manually override focus flow for non-standard layouts.
func link_ui_nodes(btn: Control, neighbor_path: NodePath) -> void:
    btn.set_focus_neighbor(SIDE_BOTTOM, neighbor_path)

# 9. Frame-Perfect Input Interception
# EXPERT NOTE: Flush the buffer before critical time-sensitive checks.
func process_combat_frame() -> void:
    if Input.is_action_just_pressed(&"attack"):
        Input.flush_buffered_events()
        # logic...

# 10. Assigning Multi-Player Authority
# EXPERT NOTE: Map inputs to specific players in local coop or split-screen.
func setup_player_authority(player_node: Node, device_id: int) -> void:
    player_node.set_multiplayer_authority(device_id)
