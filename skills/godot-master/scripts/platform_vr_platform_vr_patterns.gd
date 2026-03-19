# platform_vr_patterns.gd
extends Node

# 1. Initializing OpenXR and Enabling the Viewport
# EXPERT NOTE: use_xr must be set to true ONLY AFTER successful initialization.
func start_vr_session() -> bool:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.initialize():
        get_viewport().use_xr = true
        return true
    return false

# 2. Tracking Focus Loss (Headset Removed)
# EXPERT NOTE: Pause the game when the user takes off the headset to prevent nausea or missed info.
func setup_xr_focus_listeners() -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface:
        xr_interface.focus_lost.connect(_on_xr_focus_lost)
        xr_interface.focus_gained.connect(_on_xr_focus_gained)

func _on_xr_focus_lost() -> void:
    get_tree().paused = true

func _on_xr_focus_gained() -> void:
    get_tree().paused = false

# 3. Dynamic Foveated Rendering Setup
# EXPERT NOTE: Drastically improves performance for the Compatibility renderer.
func enable_foveation_if_supported() -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.is_foveation_supported():
        xr_interface.foveation_level = 3 # Highest level of edge pixel reduction

# 4. Triggering Controller Haptics
# EXPERT NOTE: Use for tactile feedback. frequency and amplitude help players feel interactions.
func trigger_hand_rumble(hand: StringName, amp: float = 0.5) -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface:
        # action_name, tracker_name, frequency, amplitude, duration_sec, delay_sec
        xr_interface.trigger_haptic_pulse("haptic", hand, 10.0, amp, 0.1, 0.0)

# 5. Accessing the User's Head Transform
# EXPERT NOTE: Used to position 3D UI exactly where the player is looking.
func get_eye_position() -> Transform3D:
    return XRServer.get_hmd_transform()

# 6. Fetching Physical Play Area Bounds
# EXPERT NOTE: Draw a visual boundary (Guardian/Chaperone) if the player gets near.
func get_room_bounds() -> PackedVector3Array:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface:
        return xr_interface.get_play_area()
    return PackedVector3Array()

# 7. Setting Up AR Passthrough
# EXPERT NOTE: Allows the real world to be drawn behind virtual content.
func enable_ar_passthrough() -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.is_passthrough_supported():
        xr_interface.set_environment_blend_mode(XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
        xr_interface.start_passthrough()

# 8. Handling WebXR Session Signals
# EXPERT NOTE: WebXR requires a user interaction to start and specific signal handling.
func setup_webxr_events() -> void:
    var webxr := XRServer.find_interface("WebXR")
    if webxr:
        webxr.session_started.connect(func(): get_viewport().use_xr = true)
        webxr.session_ended.connect(func(): get_viewport().use_xr = false)

# 9. Validating Initialization Status
# EXPERT NOTE: Check this before calling any XR-specific methods to prevent crashes.
func is_xr_active() -> bool:
    var xr_interface := XRServer.get_interface(0)
    return xr_interface and xr_interface.is_initialized()

# 10. Adjusting VR Viewport Scaling (Supersampling)
# EXPERT NOTE: MUST be set BEFORE xr_interface.initialize() for it to take effect.
func set_xr_resolution_scale(multiplier: float) -> void:
    var xr_interface := XRServer.find_interface("OpenXR")
    if xr_interface:
        xr_interface.render_target_size_multiplier = multiplier
