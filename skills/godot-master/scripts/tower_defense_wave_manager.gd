# godot-master/scripts/tower_defense_wave_manager.gd
extends Node

## TD Wave Manager (Expert Pattern)
## Data-driven wave spawning with support for multiple enemy types, delays, and wave intervals.

class_name WaveManager

signal wave_started(index: int)
signal wave_completed(index: int)
signal all_waves_complete

# Inner class for Wave Data (or use external Resources)
class WaveGroup:
    var enemy_scene: PackedScene
    var count: int
    var interval: float = 1.0 # Time between spawns
    var initial_delay: float = 0.0

var waves: Array[Array] = [] # Array of Arrays of WaveGroups
var current_wave_index: int = -1
var active_enemies: int = 0
var is_wave_active: bool = false

@export var spawn_points: Array[Node2D]

func _ready() -> void:
    # Example setup - in prod, load this from Resources
    _setup_debug_waves()

func start_next_wave() -> void:
    if is_wave_active:
        return
        
    current_wave_index += 1
    if current_wave_index >= waves.size():
        all_waves_complete.emit()
        return
        
    is_wave_active = true
    wave_started.emit(current_wave_index)
    
    var wave_groups = waves[current_wave_index]
    
    # Process groups in parallel or sequence? usually parallel logic per group
    for group in wave_groups:
        _process_wave_group(group)

func _process_wave_group(group: WaveGroup) -> void:
    await get_tree().create_timer(group.initial_delay).timeout
    
    for i in range(group.count):
        _spawn_enemy(group.enemy_scene)
        await get_tree().create_timer(group.interval).timeout

func _spawn_enemy(scene: PackedScene) -> void:
    var spawn = spawn_points[0] # Simple single spawn logic
    var enemy = scene.instantiate()
    spawn.add_child(enemy) # Or add to a container
    enemy.global_position = spawn.global_position
    
    active_enemies += 1
    
    # Connect signal safely
    if enemy.has_signal("died"):
        enemy.died.connect(_on_enemy_died)
    else:
        # Fallback if no specific signal, use tree_exiting (less reliable for "death" vs "freed")
        enemy.tree_exiting.connect(_on_enemy_died)

func _on_enemy_died() -> void:
    active_enemies -= 1
    if active_enemies <= 0 and _all_spawns_finished():
        is_wave_active = false
        wave_completed.emit(current_wave_index)

func _all_spawns_finished() -> bool:
    # Need a more robust check in real prod to ensure not just 0 enemies but 0 pending spawns
    # For now, simplest check:
    return true 

func _setup_debug_waves() -> void:
    # Placeholder to prevent crash
    pass

## EXPERT USAGE:
## Populate 'waves' with WaveGroup resources. Link 'spawn_points'.
## Connect to 'wave_completed' to show UI or grant gold.
