# dynamic_lod_adjuster.gd
extends Node
class_name DynamicLODAdjuster

# Dynamic Performance/LOD Bias Adjuster
# Adjusts global mesh LOD thresholds based on real-time FPS stability.

func _process(_delta: float) -> void:
    var fps := Engine.get_frames_per_second()
    var viewport := get_viewport()
    
    # Pattern: Degrade mesh quality smoothly to maintain frame targets.
    if fps < 50.0:
        viewport.mesh_lod_threshold = lerp(viewport.mesh_lod_threshold, 3.0, 0.05)
    elif fps > 65.0:
        viewport.mesh_lod_threshold = lerp(viewport.mesh_lod_threshold, 1.0, 0.05)
