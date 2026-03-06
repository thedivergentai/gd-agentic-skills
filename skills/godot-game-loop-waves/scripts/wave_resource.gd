# wave_resource.gd
# [GDSKILLS] godot-game-loop-waves
# EXPORT_REFERENCE: wave_resource.gd

extends Resource
class_name WaveResource

@export_group("Wave Metadata")
## The name of the wave for UI or logging.
@export var wave_name: String = "New Wave"
## Time in seconds before this wave starts after the previous one cleared.
@export var pre_wave_delay: float = 3.0

@export_group("Spawn Configuration")
## Dictionary of enemy scenes and their counts.
## Key: PackedScene, Value: int
@export var compositions: Dictionary = {}

## The rate at which enemies spawn (enemies per second).
@export var spawn_rate: float = 1.0

## If true, enemies spawn at random points. If false, they rotate through spawners.
@export var random_spawning: bool = true
