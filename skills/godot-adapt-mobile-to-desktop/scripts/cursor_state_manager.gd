extends Node
class_name CursorStateManager

## Expert PC Cursor Manager
## Mobile has no cursor concept. On PC, the cursor must be managed:
## Custom hardware textures, hiding during action, showing in menus.

@export var default_cursor: Texture2D
@export var crosshair_cursor: Texture2D

func _ready() -> void:
    # Set standard hardware cursors to look professional instead of default OS arrows
    if default_cursor:
        Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(0, 0))
    if crosshair_cursor:
        Input.set_custom_mouse_cursor(crosshair_cursor, Input.CURSOR_CROSS, Vector2(16, 16))

func set_combat_mode(active: bool) -> void:
    if active:
        # Hide standard cursor, switch to crosshair or fully captured
        Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
    else:
        # Released for menu usage
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _notification(what: int) -> void:
    # Hide cursor if the game window loses focus, to not confuse the user's OS usage
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        pass # Optional: Reset to OS default 
