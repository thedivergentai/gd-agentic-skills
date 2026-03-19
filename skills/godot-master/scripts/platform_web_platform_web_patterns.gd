# platform_web_patterns.gd
extends Node

# 1. Checking Web Browser Context
# EXPERT NOTE: Simple check to apply web-specific optimizations.
func is_web_runtime() -> bool:
    return OS.has_feature(&"web")

# 2. Safe Fullscreen Request
# EXPERT NOTE: Browsers block fullscreen/mouse-lock unless initiated by a direct user input event.
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"toggle_fullscreen"):
        # This occurs within an input call, satisfying the user-activation requirement.
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# 3. Asynchronous HTTP Data Fetching
# EXPERT NOTE: Low-level TCP is forbidden in browsers. HTTPRequest is the safeFetch abstraction.
func fetch_api_data(url: String) -> void:
    var http := HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(func(r, c, h, b): 
        print("Data received: ", b.get_string_from_utf8())
        http.queue_free()
    )
    http.request(url)

# 4. Checking WebXR Availability
# EXPERT NOTE: Not all desktop browsers support WebXR yet. Check supports signal.
func check_web_xr_support() -> void:
    var webxr := XRServer.find_interface("WebXR") as WebXRInterface
    if webxr:
        webxr.session_supported.connect(_on_webxr_supported)
        webxr.is_session_supported("immersive-vr")

func _on_webxr_supported(session_type: String, supported: bool) -> void:
    print("XR Session ", session_type, " supported: ", supported)

# 5. Handling WebXR Input Modalities
# EXPERT NOTE: Identify if input is gaze-based or a tracked pointer.
func process_webxr_input(source_id: int) -> void:
    var webxr := XRServer.find_interface("WebXR") as WebXRInterface
    if webxr:
        var mode := webxr.get_input_source_target_ray_mode(source_id)
        if mode == WebXRInterface.TARGET_RAY_MODE_TRACKED_POINTER:
            print("Tracked controller active.")

# 6. Lowering Visuals Dynamically for WebGL 2.0
# EXPERT NOTE: Disable expensive TAA/MSAA if the browser environment is struggling.
func optimize_visuals_for_web() -> void:
    if OS.has_feature(&"web"):
        get_viewport().use_taa = false
        get_viewport().msaa_3d = Viewport.MSAA_DISABLED

# 7. Safe Async Clipboard Usage
# EXPERT NOTE: Requires secure context (HTTPS). Check feature flag before use.
func copy_to_web_clipboard(text: String) -> void:
    if OS.has_feature(&"web") and DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
        DisplayServer.clipboard_set(text)

# 8. Handling Apple Web (iOS Safari)
# EXPERT NOTE: iOS Safari has specific quirks (like audio context locks).
func is_safari_ios() -> bool:
    return OS.has_feature(&"web_ios")

# 9. Establishing WebSocket Connectivity
# EXPERT NOTE: The ONLY viable real-time multiplayer protocol for standard web exports.
func connect_via_websocket(url: String) -> void:
    var peer := WebSocketMultiplayerPeer.new()
    if peer.create_client(url) == OK:
        multiplayer.multiplayer_peer = peer

# 10. Programmatic Canvas Resize Policy
# EXPERT NOTE: Control how the HTML canvas stretches within the browser container.
func set_web_canvas_policy() -> void:
    # 0 = Proportional, 1 = Full window, 2 = Programmatic
    ProjectSettings.set_setting("html/canvas_resize_policy", 2)
