# fps_camera_look.gd
extends Camera3D
class_name FPSCameraLook

# Asynchronous FPS Mouse Look
# Separates camera rotation from the physics tick to ensure zero-latency aiming.

@export var mouse_sensitivity := 0.002
var _rot_x := 0.0
var _rot_y := 0.0

func _unhandled_input(event: InputEvent) -> void:
    # Pattern: Capture mouse motion independent of the physics frame.
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _rot_x -= event.relative.y * mouse_sensitivity
        _rot_y -= event.relative.x * mouse_sensitivity
        
        # Clamp pitch to prevent the camera from flipping.
        _rot_x = clampf(_rot_x, -PI/2, PI/2)
        
        # Pattern: Reset transform and apply local rotations to avoid precision loss.
        transform.basis = Basis()
        rotate_object_local(Vector3.UP, _rot_y)
        rotate_object_local(Vector3.RIGHT, _rot_x)
