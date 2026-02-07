# skills/2d-physics/code/collision_setup.gd
extends Node

## Collision Matrix & CCD Professional Standard

# --- 1. Recommended Layer Map ---
# Configure these in Project Settings -> Layer Names -> 2D Physics
enum CollisionLayer {
    WORLD = 1,      # Static environment
    PLAYER = 2,     # Player Character
    ENEMIES = 4,    # Enemy Characters
    PROJECTILES = 8,# High-speed bullets (Use CCD)
    HURTBOXES = 16, # Area2Ds for damage detection
    INTERACTABLES = 32
}

# --- 2. Continuous Collision Detection (CCD) ---
func setup_bullet(bullet: RigidBody2D) -> void:
    # REQUIRED for small, fast objects to prevent 'tunneling'
    bullet.continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
    
    # Also set collision mask to only hit what it needs to
    bullet.collision_mask = CollisionLayer.WORLD | CollisionLayer.ENEMIES

# --- 3. Optimization Tip ---
# Disable 'Contact Monitor' unless you actually need the 'body_entered' signal.
# RigidBody2D 'move_and_collide' is more performant than signal-based detection 
# for hundreds of active projectiles.
