class_name SecretRandomEncounterSpawner
extends Node

## Expert Rare Encounter Spawner.
## Weighted random system for spawning 'Secret Vendors' or rare entities.

@export var rare_entity_scene: PackedScene
@export var spawn_chance: float = 0.01 # 1% chance

func attempt_spawn(spawn_parent: Node, spawn_pos: Vector3) -> void:
	if randf() <= spawn_chance:
		var instance = rare_entity_scene.instantiate()
		spawn_parent.add_child(instance)
		instance.global_position = spawn_pos

## Rule: Rare encounters should have a 'Pity' timer if they are required for achievements.
