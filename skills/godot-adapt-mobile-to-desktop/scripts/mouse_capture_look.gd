extends Node3D
class_name MouseCaptureLook

## Expert Mouse Capture Controller
## When porting a mobile dual-stick shooter or swipe-look game to PC,
## you must strictly capture the mouse and accumulate relative motion.

@export var max_pitch: float = 85.0
@export var min_pitch: float = -85.0
@export var mouse_sensitivity: float = 0.002

@onready var pitch_pivot: Node3D = $PitchPivot
var is_captured: bool = false

func _ready() -> void:
    capture_mouse()

func capture_mouse() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    is_captured = true

func release_mouse() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    is_captured = false

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        release_mouse()
    elif event.is_action_pressed("shoot") and not is_captured:
        capture_mouse()
        
    if is_captured and event is InputEventMouseMotion:
        # Rotate horizontally (yaw) around the root object
        rotate_y(-event.relative.x * mouse_sensitivity)
        
        # Rotate vertically (pitch) around the inner pivot
        pitch_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        
        # Clamp pitch to avoid looking backwards upside down
        pitch_pivot.rotation.x = clamp(
            pitch_pivot.rotation.x, 
            deg_to_rad(min_pitch), 
            deg_to_rad(max_pitch)
        )
