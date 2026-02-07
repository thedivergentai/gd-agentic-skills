# skills/input-handling/code/input_buffer_manager.gd
extends Node

## Input Buffer Manager Expert Pattern
## Implements "Input Buffering" for responsive action-game controls.

@export var buffer_window_frames: int = 10
var _buffer: Dictionary = {} # ActionName -> FrameCount

func _process(_delta: float) -> void:
    # 1. Decay the Buffer
    for action in _buffer.keys():
        _buffer[action] -= 1
        if _buffer[action] <= 0:
            _buffer.erase(action)

func _unhandled_input(event: InputEvent) -> void:
    # 2. Action-based Input Capture
    # Professional games NEVER check for individual keys in logic.
    if event is InputEventAction and event.is_pressed():
        _buffer[event.action] = buffer_window_frames

func is_action_buffered(action: String) -> bool:
    return _buffer.has(action)

func consume_action(action: String) -> void:
    _buffer.erase(action)

## EXPERT NOTE:
## Use the 'Jump Buffering' pattern: Check 'is_action_buffered(\"jump\")' 
## when the character touches the 'is_on_floor()' ground to allow 
## jumping even if the button was pressed frames early.
## Combine with 'Coyote Time' for the industry-standard "Tight Controls" feel.
## For 'input-handling', implement 'Action Remapping' by saving modified 
## 'InputMap' settings to a 'ConfigFile' for persistence.
