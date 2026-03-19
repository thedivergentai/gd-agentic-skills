# minigame_player_controller.gd
extends CharacterBody3D
class_name MinigamePlayerController

# Raw Device Input Polling
# Reads analog data directly from a specific joypad ID for local multiplayer.

@export var device_id: int = -1
@export var speed := 10.0

func _physics_process(_delta: float) -> void:
    if device_id == -1: return
    
    # Pattern: Bypassing InputMap for precise multi-device polling.
    var x := Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
    var y := Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
    
    var dir := Vector3(x, 0, y)
    if dir.length() > 0.2: # Deadzone
        velocity = dir * speed
    else:
        velocity = Vector3.ZERO
        
    move_and_slide()
