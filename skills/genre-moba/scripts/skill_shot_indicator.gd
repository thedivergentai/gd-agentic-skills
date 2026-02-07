# skills/genre-moba/code/skill_shot_indicator.gd
extends Node2D

## Skill-Shot Indicator Expert Pattern
## Procedural ground telegraphing for ability paths.

@export var indicator_color: Color = Color(1, 0, 0, 0.4)
var _path_width: float = 50.0
var _path_length: float = 400.0
var _is_active: bool = false

func _draw() -> void:
    if not _is_active: return
    
    # 1. Visual Telegraphing
    # Draw a rectangle representing the skill-shot collision box.
    var rect = Rect2(0, -_path_width/2, _path_length, _path_width)
    draw_rect(rect, indicator_color, true)
    draw_rect(rect, Color.WHITE, false, 2.0) # Outline

func show_indicator(width: float, length: float) -> void:
    _path_width = width
    _path_length = length
    _is_active = true
    queue_redraw()

func hide_indicator() -> void:
    _is_active = false
    queue_redraw()

func _physics_process(_delta: float) -> void:
    if _is_active:
        # 2. Input Alignment
        # The indicator should always point toward the mouse cursor.
        look_at(get_global_mouse_position())

## EXPERT NOTE:
## For performance, use a single MeshInstance2D or a Shader-based Plane 
## instead of _draw() if many indicators are active simultaneously.
