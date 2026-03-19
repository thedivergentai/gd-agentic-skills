extends Node
class_name AdaptiveMobileResolution

## Expert Viewport Resolution Scaler
## Separates UI rendering from 3D world rendering.
## Dynamically drops the 3D resolution scale down to keep 60 FPS on weak GPUs
## while leaving the 2D UI incredibly sharp.

@export var target_fps: int = 60
@export var check_interval: float = 2.0
@export var min_scale: float = 0.3
@export var scale_step: float = 0.1

var timer: float = 0.0

func _ready() -> void:
    # Requires Project Settings -> Display -> Window -> Stretch -> Mode: 'canvas_items'
    if not OS.has_feature("mobile"):
        set_process(false)

func _process(delta: float) -> void:
    timer += delta
    if timer >= check_interval:
        timer = 0.0
        var current_fps = Engine.get_frames_per_second()
        var current_scale = get_viewport().scaling_3d_scale
        
        if current_fps < target_fps - 5:
            # Dropping frames, decrease 3D resolution
            var new_scale = clampf(current_scale - scale_step, min_scale, 1.0)
            get_viewport().scaling_3d_scale = new_scale
            
        elif current_fps > target_fps + 2 and current_scale < 1.0:
            # Plenty of headroom, try increasing resolution
            var new_scale = clampf(current_scale + (scale_step / 2.0), min_scale, 1.0)
            get_viewport().scaling_3d_scale = new_scale
