# SDFGI Quality and Probe Control
extends WorldEnvironment

## SDFGI is powerful but expensive. This script manages probe cell size
## based on the current graphics preset.

func set_sdfgi_preset(is_high_end: bool) -> void:
    var env = environment
    env.sdfgi_enabled = true
    
    if is_high_end:
        env.sdfgi_min_cell_size = 0.2
        env.sdfgi_use_occlusion = true
        env.sdfgi_read_sky_light = true
    else:
        env.sdfgi_min_cell_size = 0.8 # Larger cells = lower CPU cost
        env.sdfgi_use_occlusion = false
        env.sdfgi_read_sky_light = false
        
    # Architecture Tip: SDFGI probes are updated over multiple frames.
    # Rapid camera movement can cause 'ghosting' at small cell sizes.
