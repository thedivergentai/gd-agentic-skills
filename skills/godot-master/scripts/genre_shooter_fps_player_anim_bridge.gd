# player_anim_bridge.gd
extends Node
class_name PlayerAnimBridge

# Local Velocity for Animation BlendTrees
# Extracts local lateral movement for strafing blend states.

@export var player: CharacterBody3D
@export var anim_tree: AnimationTree

func _process(_delta: float) -> void:
    if not player or not anim_tree: return
    
    # Pattern: Inverse basis transform to get local-space velocity.
    var local_vel := player.global_transform.basis.inverse() * player.velocity
    var blend_pos := Vector2(local_vel.x, local_vel.z)
    
    # Update BlendTree parameters.
    anim_tree.set(&"parameters/movement/blend_position", blend_pos)
