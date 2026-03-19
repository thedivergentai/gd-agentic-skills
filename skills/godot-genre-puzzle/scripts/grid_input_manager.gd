# grid_input_manager.gd
extends Node
class_name GridInputManager

# Routing Unhandled Grid Input
# Intercepts clicks strictly when the GUI has not consumed them.

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        var grid_pos = _screen_to_grid(event.position)
        _handle_grid_click(grid_pos)
        
        # Pattern: Consume immediately to stop propagation.
        get_viewport().set_input_as_handled()

func _screen_to_grid(_pos: Vector2) -> Vector2i:
    return Vector2i.ZERO

func _handle_grid_click(_grid_pos: Vector2i) -> void:
    pass
