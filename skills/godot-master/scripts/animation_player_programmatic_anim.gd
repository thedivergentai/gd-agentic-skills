# skills/animation-player/code/programmatic_anim.gd
extends Node

## Programmatic Track Generation Expert Pattern
## Technical blueprints for building Animation resources via code.

func create_procedural_transition(node: Node3D, target_pos: Vector3) -> Animation:
    var anim := Animation.new()
    anim.length = 1.0
    
    # 1. Add a Property Track for 'position'
    var track_index := anim.add_track(Animation.TYPE_VALUE)
    anim.track_set_path(track_index, str(get_path_to(node)) + ":position")
    
    # 2. Insert Keyframes
    anim.track_insert_key(track_index, 0.0, node.position)
    anim.track_insert_key(track_index, 1.0, target_pos)
    
    # 3. Set Easing (Cubic Bezier)
    anim.track_set_key_transition(track_index, 0, 0.5) # Smoothing-in
    
    # 4. Expert: Enable Storage Compression (Godot 4+)
    # This reduces memory footprint for long procedural animations.
    # anim.step = 0.01 
    
    return anim

## WHY THIS WAY?
## Procedural animations allow for dynamic transitions that can't be baked 
## into FBX files, such as moving to a dynamically calculated point in world space.
