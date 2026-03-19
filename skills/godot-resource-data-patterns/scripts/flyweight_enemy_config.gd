# flyweight_enemy_config.gd
# Using Resources to configure many entities efficiently
extends CharacterBody2D

# EXPERT NOTE: Instead of exporting 20 variables, export 1 Resource.
# This makes swapping "Normal" for "Elite" enemy stats instant.

@export var config: EnemyConfigResource

func _ready():
	if config:
		$Sprite3D.texture = config.skin
		$HealthComponent.max_health = config.hp
