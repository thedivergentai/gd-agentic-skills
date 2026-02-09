# skills/shaders-basics/scripts/shader_parameter_animator.gd
extends Node

## Shader Parameter Animator (Expert Pattern)
## Animates shader uniforms via code (Singular Manager).
## Prevents creating unique Tweens for every single visual effect instance.

class_name ShaderAnimator

static func animate_float(material: ShaderMaterial, param: String, from: float, to: float, duration: float) -> void:
    if not material: return
    
    var tree = Engine.get_main_loop() as SceneTree
    if not tree: return
    
    var tween = tree.create_tween()
    tween.tween_method(
        func(val): material.set_shader_parameter(param, val),
        from, to, duration
    )

static func animate_vec3(material: ShaderMaterial, param: String, from: Vector3, to: Vector3, duration: float) -> void:
    if not material: return
    var tree = Engine.get_main_loop() as SceneTree
    var tween = tree.create_tween()
    tween.tween_method(
        func(val): material.set_shader_parameter(param, val),
        from, to, duration
    )

static func pulse_param(material: ShaderMaterial, param: String, min_val: float, max_val: float, speed: float) -> void:
    # Requires an active node to process
    pass # Implementation requires active processing

## EXPERT USAGE:
## Call ShaderAnimator.animate_float(mat, "dissolve", 0.0, 1.0, 2.0)
## Handles the tween creation automatically.
