extends Control
class_name DynamicVirtualJoystick

## Expert Virtual Joystick Spawner
## Instead of a hardcoded bottom-left position, this joystick appears 
## exactly where the user touches on the left half of the screen.

signal joystick_updated(direction: Vector2)

@export var max_radius: float = 100.0
@export var return_speed: float = 20.0

@onready var background: Sprite2D = $Background
@onready var handle: Sprite2D = $Handle

var active_touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO

func _ready() -> void:
    modulate.a = 0.0 # Hidden by default
    
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        # Only activate on the left half of the screen
        if event.pressed and active_touch_index == -1 and event.position.x < get_viewport_rect().size.x / 2.0:
            active_touch_index = event.index
            joystick_center = event.position
            global_position = joystick_center
            handle.position = Vector2.ZERO
            modulate.a = 1.0 # Show
            
        elif not event.pressed and event.index == active_touch_index:
            active_touch_index = -1
            modulate.a = 0.0 # Hide
            joystick_updated.emit(Vector2.ZERO)
            
    elif event is InputEventScreenDrag and event.index == active_touch_index:
        var drag_vector = event.position - joystick_center
        var clamped_drag = drag_vector.limit_length(max_radius)
        
        handle.position = clamped_drag
        var normalized_direction = clamped_drag / max_radius
        joystick_updated.emit(normalized_direction)
