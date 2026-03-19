# platform_desktop_patterns.gd
extends Node

# 1. Enabling Client-Side Decorations (macOS/Windows)
# EXPERT NOTE: Custom title bars create a premium "App" feel.
func setup_app_styles() -> void:
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
    # Further logic for custom minimize/close buttons would go here

# 2. Triggering Native OS File Dialogs
# EXPERT NOTE: Users prefer the system-native look over Godot's built-in FileDialog.
func open_file_browser(callback: Callable) -> void:
    DisplayServer.file_dialog_show(
        "Open Configuration", 
        "user://", 
        "", 
        false, 
        DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, 
        ["*.json"], 
        callback
    )

# 3. Spawning Detached Tool Windows
# EXPERT NOTE: Multi-window support is a powerful Desktop exclusive feature in Godot 4.
func create_secondary_display(scene: PackedScene) -> Window:
    var popup := Window.new()
    popup.title = "Side Tool"
    popup.unresizable = false
    add_child(popup)
    popup.add_child(scene.instantiate())
    popup.popup_centered()
    return popup

# 4. Opening Encoded URLs
# EXPERT NOTE: Always encode URIs to prevent injection or broken links on different OSs.
func open_support_page() -> void:
    var uri := "https://docs.godotengine.org".uri_encode()
    OS.shell_open(uri)

# 5. Low Processor Mode (App Optimization)
# EXPERT NOTE: Essential for background tools (editors, launchers) to save power.
func enable_eco_mode() -> void:
    OS.low_processor_usage_mode = true
    OS.low_processor_usage_mode_sleep_usec = 6900 # Sleep ~7ms to save CPU

# 6. Polling Screen Pixel Color
# EXPERT NOTE: Useful for eye-dropper tools or dynamic ambient lighting from screen content.
func get_pixel_at_cursor() -> Color:
    var pos := DisplayServer.mouse_get_position()
    return DisplayServer.screen_get_pixel(pos)

# 7. OS Drag-and-Drop Callback
# EXPERT NOTE: Enhances user experience for level editors or file importers.
func setup_drag_drop() -> void:
    DisplayServer.window_set_drop_files_callback(_on_files_dropped)

func _on_files_dropped(files: PackedStringArray) -> void:
    for f in files:
        print("User dropped: ", f)

# 8. macOS App Sandbox Verification
# EXPERT NOTE: Entitlements on macOS can block logic. Always check the environment.
func is_in_sandbox() -> bool:
    return OS.has_feature(&"macos") and OS.is_sandboxed()

# 9. Creating System Tray (Status) Indicators
# EXPERT NOTE: Allows apps to "minimize to tray" on Windows/Linux/macOS.
func register_tray_icon(icon: Texture2D) -> void:
    DisplayServer.create_status_indicator(icon, "Godot Agent", _on_tray_clicked)

func _on_tray_clicked(btn: int) -> void:
    if btn == MOUSE_BUTTON_LEFT:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 10. Background Process Forking
# EXPERT NOTE: Launch a separate headless instance for heavy data tasks or dedicated servers.
func fork_background_process() -> int:
    return OS.create_process(OS.get_executable_path(), ["--headless", "--no-window"])
