# physics_layers_3d_config.gd
# 3D Collision matrix architecture using bitmasks
extends Node

enum Layer {
	WORLD = 1 << 0,
	PLAYER = 1 << 1,
	ENEMY = 1 << 2,
	BULLET = 1 << 3,
	INTERACTABLE = 1 << 4
}

func apply_bullet_collision(body: CollisionObject3D):
	# Bullets are on BULLET layer
	body.collision_layer = Layer.BULLET
	# Mask for WORLD and ENEMY
	body.collision_mask = Layer.WORLD | Layer.ENEMY
