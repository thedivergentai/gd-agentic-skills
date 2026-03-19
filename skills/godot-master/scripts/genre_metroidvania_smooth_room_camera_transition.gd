# smooth_room_camera_transition.gd
extends Camera2D
class_name SmoothRoomCameraTransition

# Smooth Room Camera Transition (Tweening)
# Interpolates camera limits to snap to new room borders without visual snapping.

var _active_tween: Tween

func transition_to_bounds(new_limits: Rect2) -> void:
    # Clean up any existing transition.
    if _active_tween:
        _active_tween.kill()
        
    _active_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    
    # Smoothly animate the limits. Note: limits must be integers.
    _active_tween.tween_property(self, ^"limit_left", int(new_limits.position.x), 0.5)
    _active_tween.tween_property(self, ^"limit_right", int(new_limits.end.x), 0.5)
    _active_tween.tween_property(self, ^"limit_top", int(new_limits.position.y), 0.5)
    _active_tween.tween_property(self, ^"limit_bottom", int(new_limits.end.y), 0.5)
