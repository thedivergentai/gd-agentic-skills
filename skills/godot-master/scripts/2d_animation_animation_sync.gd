# godot-master/scripts/2d_animation_animation_sync.gd
extends CharacterBody2D

## 2D Animation Sync Expert Pattern
## This script demonstrates:
## 1. Method track triggers for frame-perfect logic (SFX/VFX)
## 2. Signal-driven async gameplay orchestration
## 3. AnimationTree blend space management

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

signal attack_landed(target: Node2D)
signal footstep_triggered(position: Vector2)

# --- 1. Method Track Triggers ---
# These functions should be called via 'Method Track' keyframes in AnimationPlayer
# Use 'emit_footstep' at the exact frame the foot touches the ground.

func emit_footstep() -> void:
    footstep_triggered.emit(global_position)
    # Expert Tip: Use AudioServer or a dedicated SoundPool for performance
    # print_debug("Footstep at ", Time.get_ticks_msec())

func emit_attack_hitbox() -> void:
    # Logic to enable/disable hitboxes based on animation frames
    # This is more precise than timers or polling
    pass

# --- 2. Signal-Driven Async Logic ---
# Patterns for connecting animation 'finished' signals to gameplay events.

func perform_action_sequence() -> void:
    # Syncing gameplay logic with animation completion using await
    playback.travel("SpecialAction")
    
    # Wait for the animation to finish OR for a specific frame event
    await anim_player.animation_finished
    
    # Trigger secondary effects once animation is officially done
    _on_action_completed()

func _on_action_completed() -> void:
    # Resume movement or trigger next state
    pass

# --- 3. Blend Space Smoothing ---
# Expert handling of AnimationTree parameters for fluid transitions.

func update_movement_animation(velocity_vector: Vector2) -> void:
    # Use 'lerp' or 'move_toward' on the blend space position 
    # if you want custom logic beyond the AnimationTree's built-in damping.
    var target_blend: Vector2 = velocity_vector.normalized()
    
    # parameters/IdleRun/blend_position is a common path for 2D BlendSpaces
    anim_tree.set("parameters/IdleRun/blend_position", target_blend)
    
    # Logic for character flipping based on blend direction
    if target_blend.x != 0:
        $Sprite2D.flip_h = target_blend.x < 0
