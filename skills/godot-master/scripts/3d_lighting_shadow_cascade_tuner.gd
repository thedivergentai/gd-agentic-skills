# Dynamic Shadow Cascade Tuner
extends DirectionalLight3D

## PC gamers expect high quality up close and efficiency at distance.
## Tuner script to adjust shadow split distances dynamically.

@onready var camera = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
    if !camera: return
    
    # Architecture Tip: Increase cascade quality for low-angle sun
    var dot_product = global_transform.basis.z.dot(Vector3.UP)
    if dot_product > 0.8: # Noon-ish
        directional_shadow_split_1 = 0.1
    else: # Sunset/Dusk - long shadows need more split resolution
        directional_shadow_split_1 = 0.05
    
    # Blend splits to remove visible borders
    directional_shadow_blend_splits = true
