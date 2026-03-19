extends Node
class_name DynamicWindowManager

## Expert Desktop Window Manager
## Mobile games are always full screen. PC gamers demand Borderless Windowed,
## standard Windowed, and Full Screen Exclusive.

enum WindowMode {
    WINDOWED,
    FULLSCREEN,
    BORDERLESS_FULLSCREEN
}

var current_mode: WindowMode = WindowMode.WINDOWED

func _input(event: InputEvent) -> void:
    # Standard PC shortcut: Alt+Enter to toggle fullscreen
    if event.is_action_pressed("toggle_fullscreen") or (event is InputEventKey and event.keycode == KEY_ENTER and event.alt_pressed):
        if current_mode == WindowMode.WINDOWED:
            set_mode(WindowMode.BORDERLESS_FULLSCREEN)
        else:
            set_mode(WindowMode.WINDOWED)

func set_mode(mode: WindowMode) -> void:
    current_mode = mode
    match current_mode:
        WindowMode.WINDOWED:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
            DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
        WindowMode.FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
            DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
        WindowMode.BORDERLESS_FULLSCREEN:
            # Borderless fills the screen but allows fast alt-tabbing on modern OSs
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
            DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
            
    print("Window mode set to: ", WindowMode.keys()[current_mode])
