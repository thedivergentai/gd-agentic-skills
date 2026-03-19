extends Control
class_name DesktopUISHRINKER

## Expert Desktop UI Scaler
## When migrating a mobile game to PC, buttons are usually MASSIVE (to fit thick thumbs).
## Using the `DisplayServer.screen_get_dpi()` we can selectively shrink the Control tree on PC monitors.

@export var shrink_factor: float = 0.65

func _ready() -> void:
    if not OS.has_feature("mobile"): # If we are on Windows/macOs/Linux
        _shrink_recursive(self)

func _shrink_recursive(node: Node) -> void:
    if node is Control:
        # If the button had a custom minimum size of 150x150 for touch screens, scale it down
        var old_min = node.custom_minimum_size
        if old_min.x > 0 and old_min.y > 0:
            node.custom_minimum_size = old_min * shrink_factor
            
        # Optional: reduce font sizes in theme overrides
        if node.has_theme_font_size_override("font_size"):
            var current_size = node.get_theme_font_size("font_size")
            node.add_theme_font_size_override("font_size", int(current_size * shrink_factor))
            
    for child in node.get_children():
        _shrink_recursive(child)
