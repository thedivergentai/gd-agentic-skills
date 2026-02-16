# godot-master/scripts/adapt_desktop_mobile_virtual_joystick.gd
extends Control

## Virtual Joystick Expert Pattern
## Production-ready joystick with multi-touch support and visual feedback.

class_name VirtualJoystick

signal direction_changed(direction: Vector2)

@export var dead_zone: float = 0.2
@export var max_distance: float = 100.0
@export var clamp_zone: bool = true

# UI References
@onready var base: Sprite2D = $Base
@onready var knob: Sprite2D = $Knob

# State
var _touch_index: int = -1
var _stick_center: Vector2

func _ready() -> void:
	# Ensure pivots are centered
	if base: _stick_center = base.position
	
func _input(event: InputEvent) -> void:
    if not (base and knob): return

    if event is InputEventScreenTouch:
        if event.pressed:
            if _touch_index == -1 and _is_point_inside_base(event.position):
                _touch_index = event.index
                _update_joystick(event.position)
        elif event.index == _touch_index:
            _reset_joystick()
            
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            _update_joystick(event.position)

func _is_point_inside_base(point: Vector2) -> bool:
    var global_rect = base.get_rect()
    global_rect.position += base.global_position - (base.texture.get_size() / 2.0)
    return global_rect.has_point(point)

func _update_joystick(touch_pos: Vector2) -> void:
    var local_pos = to_local(touch_pos)
    var vector = local_pos - _stick_center
    var dist = vector.length()
    
    if clamp_zone and dist > max_distance:
        vector = vector.normalized() * max_distance
        
    knob.position = _stick_center + vector
    
    var output = vector / max_distance
    if output.length() < dead_zone:
        output = Vector2.ZERO
        
    direction_changed.emit(output)

func _reset_joystick() -> void:
    _touch_index = -1
    knob.position = _stick_center
    direction_changed.emit(Vector2.ZERO)

## EXPERT USAGE:
## Instantiate in MobileHUD. Connect 'direction_changed' to Player movement.
