extends MarginContainer
class_name UISafeAreaMargins

## Expert Mobile Notch Avoidance
## On iPhone and Android, screens have physical cutouts (notches, hole punches).
## Instead of guessing, we use the OS safe area Rect2 to apply Margins accurately.

func _ready() -> void:
    get_viewport().size_changed.connect(_apply_safe_area)
    _apply_safe_area()

func _apply_safe_area() -> void:
    if not OS.has_feature("mobile"):
        return
        
    var safe_area: Rect2i = DisplayServer.get_display_safe_area()
    var window_size: Vector2i = DisplayServer.window_get_size()
    
    var left_margin = safe_area.position.x
    var top_margin = safe_area.position.y
    var right_margin = window_size.x - safe_area.end.x
    var bottom_margin = window_size.y - safe_area.end.y
    
    add_theme_constant_override("margin_left", left_margin)
    add_theme_constant_override("margin_top", top_margin)
    add_theme_constant_override("margin_right", right_margin)
    add_theme_constant_override("margin_bottom", bottom_margin)
