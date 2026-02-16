# godot-master/scripts/physics_3d_ragdoll_manager.gd
extends Node

## Ragdoll Manager (Expert Pattern)
## Manages transition of character from Animated to Ragdoll state.
## Applies initial impulse for "meaty" impacts.

class_name RagdollManager

@export var skeleton: Skeleton3D
@export var character_collider: CollisionShape3D

func activate_ragdoll(impulse_dir: Vector3 = Vector3.ZERO, impulse_force: float = 0.0) -> void:
    if not skeleton: return
    
    # 1. Disable Main Collider (so it doesn't fight bones)
    if character_collider:
        character_collider.disabled = true
        
    # 2. Start Simulation
    skeleton.physical_bones_start_simulation()
    
    # 3. Apply Impulse (e.g., Shotgun blast)
    if impulse_force > 0.0:
        # Apply to specific bone or all? usually torso (Bone 0 or near center)
        # Getting physical bone by name is tricky, usually iterate children
        for child in skeleton.get_children():
            if child is PhysicalBone3D:
                child.apply_central_impulse(impulse_dir * impulse_force)
                # Break loop if only hitting one, or apply force field logic

func deactivate_ragdoll() -> void:
    if not skeleton: return
    
    skeleton.physical_bones_stop_simulation()
    if character_collider:
        character_collider.disabled = false
        
    # Note: Blending back to animation pose is complex 
    # and requires manual bone transform interpolation.

## EXPERT USAGE:
## Call upon death. Pass 'hit_normal * -1' as impulse_dir.
