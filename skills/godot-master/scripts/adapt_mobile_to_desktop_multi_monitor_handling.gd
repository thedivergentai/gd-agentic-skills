extends Node
class_name MultiMonitorSnapManager

## Expert Multiple Monitor Detection
## Unlike mobile, PC users frequently have 2 or 3 monitors. 
## We must intelligently query the OS and spawn the game on the correct active screen.

func _ready() -> void:
    # Small delay to ensure the OS window server is fully initialized post-launch
    get_tree().create_timer(0.2).timeout.connect(_center_on_active_monitor)

func _center_on_active_monitor() -> void:
    var screen_count = DisplayServer.get_screen_count()
    if screen_count <= 1: 
        return # Standard single monitor, ignore

    # We determine the "Active" monitor by checking where the mouse pointer currently is
    var mouse_pos = DisplayServer.mouse_get_position()
    var active_screen = DisplayServer.get_screen_from_rect(Rect2i(mouse_pos, Vector2i(1,1)))
    
    # Get the position and size of the active screen
    var screen_pos = DisplayServer.screen_get_position(active_screen)
    var screen_size = DisplayServer.screen_get_size(active_screen)
    
    var window_size = DisplayServer.window_get_size()
    
    # Calculate perfect center
    var new_window_pos = screen_pos + (screen_size / 2) - (window_size / 2)
    
    # Apply
    DisplayServer.window_set_current_screen(active_screen)
    DisplayServer.window_set_position(new_window_pos)

    print("Snapped game window to Monitor: ", active_screen)
