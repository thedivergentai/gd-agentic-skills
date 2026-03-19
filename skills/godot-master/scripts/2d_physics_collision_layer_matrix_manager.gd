# collision_layer_matrix_manager.gd
# Advanced collision layer/mask management logic
extends Node

# EXPERT NOTE: Use Bit-shifting or Enums for collision layers 
# rather than magic numbers to prevent 'Collision Matrix Hell'.

enum Layer {
	WORLD = 1,
	PLAYER = 2,
	ENEMY = 4,
	PROJECTILE = 8,
	HAZARD = 16
}

func setup_projectile(node: CollisionObject2D):
	# Projectiles should be on PROJECTILE layer (8)
	# And mask for WORLD (1) and ENEMY (4)
	node.collision_layer = Layer.PROJECTILE
	node.collision_mask = Layer.WORLD | Layer.ENEMY

func set_ignore_player(node: CollisionObject2D, ignore: bool):
	if ignore:
		node.collision_mask &= ~Layer.PLAYER # Bitwise NOT and AND to remove
	else:
		node.collision_mask |= Layer.PLAYER # Bitwise OR to add
