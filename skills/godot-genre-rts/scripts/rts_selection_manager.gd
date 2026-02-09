# skills/genre-rts/scripts/rts_selection_manager.gd
extends Node2D

## RTS Selection Manager (Expert Pattern)
## Handles 2D/3D unit selection via drag box and single clicks.
## Supports Shift-Add and broadcasting commands to selected units.

class_name RTSSelectionManager

signal selection_changed(selected_units: Array)

@export var selection_box_color: Color = Color(0, 1, 0, 0.3)
@export var selection_border_color: Color = Color(0, 1, 0, 1)

var selected_units: Array = []
var drag_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var _box_rect: Rect2

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                _start_drag(event.position)
            else:
                _end_drag(event.position)
        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            _issue_move_command(get_global_mouse_position()) # Or raycast for 3D

    elif event is InputEventMouseMotion and is_dragging:
        queue_redraw()

func _start_drag(pos: Vector2) -> void:
    drag_start = pos
    is_dragging = true

func _end_drag(pos: Vector2) -> void:
    is_dragging = false
    queue_redraw()
    
    var drag_rect = Rect2(drag_start, pos - drag_start).abs()
    
    if not Input.is_key_pressed(KEY_SHIFT):
        _deselect_all()
    
    if drag_rect.size.length_squared() < 100:
        # Single Click
        _select_at_point(pos)
    else:
        # Box Select
        _select_in_rect(drag_rect)
    
    selection_changed.emit(selected_units)

func _select_at_point(pos: Vector2) -> void:
    # 2D Implementation (Physics Query)
    var space = get_world_2d().direct_space_state
    var query = PhysicsPointQueryParameters2D.new()
    query.position = get_global_mouse_position() # Use global for query
    query.collide_with_areas = true # Assuming units have areas or bodies
    
    var results = space.intersect_point(query)
    if not results.is_empty():
        var unit = results[0].collider
        if unit.has_method("set_selected"):
            _add_to_selection(unit)

func _select_in_rect(rect: Rect2) -> void:
    # Need to convert Viewport Screen Rect to World Rect if camera moves
    # For now assuming simple 2D screen-space match or using `get_global_mouse_position` logic
    # Better: Query physics with a Shape
    
    var space = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    var shape = RectangleShape2D.new()
    shape.size = rect.size
    query.shape = shape
    query.transform = Transform2D(0, (drag_start + (rect.size / 2)) + get_canvas_transform().origin ) # Rough approximation, requires camera awareness
    
    # Actually, easiest is to iterate all "selectable" group nodes and check if inside rect
    # This avoids complex shape transform math for screen-to-world rect
    var candidates = get_tree().get_nodes_in_group("selectable")
    for unit in candidates:
        # Check if unit screen position is inside drag_rect
        var screen_pos = unit.get_global_transform_with_canvas().origin
        if rect.has_point(screen_pos):
             _add_to_selection(unit)

func _add_to_selection(unit: Node) -> void:
    if unit not in selected_units:
        selected_units.append(unit)
        unit.set_selected(true)

func _deselect_all() -> void:
    for unit in selected_units:
        if is_instance_valid(unit):
            unit.set_selected(false)
    selected_units.clear()

func _issue_move_command(target: Vector2) -> void:
    for unit in selected_units:
        if unit.has_method("move_to"):
            unit.move_to(target)

func _draw() -> void:
    if is_dragging:
        var mouse = get_local_mouse_position()
        var rect = Rect2(drag_start, mouse - drag_start)
        draw_rect(rect, selection_box_color, true)
        draw_rect(rect, selection_border_color, false, 2.0)

## EXPERT USAGE:
## Add units to "selectable" group. Implement set_selected(bool) and move_to(pos) on units.
## For 3D, replace PhysicsPointQueryParameters2D with Raycast logic.
