# platform_mobile_patterns.gd
extends Node

# 1. Processing Application Suspension
# EXPERT NOTE: Mobile OSs aggressively suspend apps. Save state immediately.
func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED:
        print("Mobile app suspended. Saving progress...")
        # SaveManager.save_game_state()

# 2. Emulating Mouse Events from Touch
# EXPERT NOTE: Allows drag/click logic to work without rewriting code for touch.
func enable_touch_emulation() -> void:
    Input.emulate_mouse_from_touch = true

# 3. Querying Safe Areas (Notch/Cutout Support)
# EXPERT NOTE: Respect camera notches so essential UI doesn't get obscured.
func adjust_ui_for_safe_area(container: Control) -> void:
    var safe_rect := DisplayServer.get_display_safe_area()
    # Apply global screen safe area to the UI container
    container.position = safe_rect.position
    container.size = safe_rect.size

# 4. Triggering the Software Keyboard
# EXPERT NOTE: Invoke the native virtual keyboard for text input fields.
func show_mobile_keyboard(current_text: String = "") -> void:
    DisplayServer.virtual_keyboard_show(current_text)

# 5. Accessing Hardware Accelerometer
# EXPERT NOTE: Use for tilt controls. Requires 'sensors/enable_accelerometer' in export.
func _physics_process(_delta: float) -> void:
    var tilt_vector := Input.get_accelerometer()
    if tilt_vector.length() > 0.1:
        # Move logic...
        pass

# 6. Invoking Native Mobile Haptics
# EXPERT NOTE: Provides tactical feedback. On Android, requires VIBRATE permission.
func trigger_short_vibration() -> void:
    Input.vibrate_handheld(250) # Duration in ms

# 7. Requesting Android Runtime Permissions
# EXPERT NOTE: Mandatory for accessing storage or camera on modern Android versions.
func request_file_permission() -> void:
    var permission := "android.permission.READ_EXTERNAL_STORAGE"
    if OS.has_feature(&"android"):
        OS.request_permission(permission)

# 8. Locking Screen Orientation Programmatically
# EXPERT NOTE: Force landscape for levels and portrait for menus if needed.
func set_portrait_mode() -> void:
    DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

# 9. Utilizing JavaClassWrapper (Android JNI)
# EXPERT NOTE: Access native Android APIs (like SDK version) via JNI bridge.
func get_android_sdk_int() -> int:
    if OS.has_feature(&"android"):
        var build_version = JavaClassWrapper.wrap("android.os.Build$VERSION")
        return build_version.SDK_INT
    return -1

# 10. Modifying Canvas Scaling for High DPI
# EXPERT NOTE: Expands the canvas to fill tall/wide screens without stretching.
func setup_mobile_resolution_policy() -> void:
    get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
