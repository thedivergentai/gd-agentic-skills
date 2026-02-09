# skills/tweening/code/juice_manager.gd
extends Node

## Tweening Expert Pattern
## Implements Custom Interpolators (Juice) and Bezier Easing.

@export var punch_curve: Curve

# 1. Custom Interpolators (tween_method)
func punch_ui(target: Control) -> void:
    var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    
    # Professional pattern: Kill previous tween to avoid conflicts.
    # target.set_meta("active_tween", tween) # Simplified tracking
    
    # Animate a custom method for values that aren't simple properties
    # e.g. Animate a shader uniform or a multi-step calculation.
    tween.tween_method(_apply_shader_distortion, 0.0, 1.0, 0.5)
    
    # 2. Sequence Management
    tween.parallel().tween_property(target, "scale", Vector2(1.2, 1.2), 0.1)
    tween.chain().tween_property(target, "scale", Vector2.ONE, 0.3)

func _apply_shader_distortion(value: float) -> void:
    # Logic for manual value interpolation
    pass

# 3. Bezier Easing via Curves
func curve_animate(target: Node2D, destination: Vector2) -> void:
    var tween = create_tween()
    
    # Expert logic: Use a Move-To-Value approach driven by a Curve.
    # This allows for high-end, artistic motion control.
    tween.tween_method(
        func(t: float): 
            var weight = punch_curve.sample(t)
            target.global_position = target.global_position.lerp(destination, weight),
        0.0, 1.0, 1.0
    )

## EXPERT NOTE:
## Use 'Scene Tree Independence': For UI elements that persist 
## across scene changes (like a loading bar), create the Tween 
## on a Global Autoload Node rather than the Control node itself.
## For 'tweening', implement 'Rhythmic Transitions': Use 
## 'tween.set_speed_scale(2.0)' to match UI animation speed to 
## the game's BPM or combat pace.
## NEVER forget to call 'kill()' on older tweens when a new action 
## interrupts an existing one (e.g. stopping a 'Hurt' shake to start 
## a 'Death' fade) to prevent property flickering.
## Use 'set_parallel()' to trigger multi-property 'Juice' (Scale, 
## Rotation, and Color) in a single rhythmic burst.
