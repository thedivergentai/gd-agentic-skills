# game_loop_waves_manager.gd
# [GDSKILLS] godot-game-loop-waves
# EXPORT_REFERENCE: wave_manager.gd

extends Node

signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal all_waves_complete()
signal enemy_spawned(enemy: Node)

@export var wave_sequence: Array[WaveResource] = []
@export var auto_start: bool = false

var current_wave_index: int = -1
var active_enemies: Array[Node] = []
var is_spawning: bool = false

func _ready() -> void:
	if auto_start:
		start_next_wave()

func start_next_wave() -> void:
	if current_wave_index + 1 >= wave_sequence.size():
		all_waves_complete.emit()
		return
		
	current_wave_index += 1
	var current_wave = wave_sequence[current_wave_index]
	
	if current_wave.pre_wave_delay > 0:
		await get_tree().create_timer(current_wave.pre_wave_delay).timeout
	
	_trigger_wave(current_wave)

func _trigger_wave(wave: WaveResource) -> void:
	is_spawning = true
	wave_started.emit(current_wave_index)
	
	var spawn_list = []
	for scene in wave.compositions:
		var count = wave.compositions[scene]
		for i in range(count):
			spawn_list.append(scene)
	
	if wave.random_spawning:
		spawn_list.shuffle()
	
	for enemy_scene in spawn_list:
		_spawn_enemy(enemy_scene)
		await get_tree().create_timer(1.0 / wave.spawn_rate).timeout
		
	is_spawning = false

func _spawn_enemy(scene: PackedScene) -> void:
	var enemy = scene.instantiate()
	add_child(enemy)
	active_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))
	enemy_spawned.emit(enemy)

func _on_enemy_removed(enemy: Node) -> void:
	active_enemies.erase(enemy)
	if active_enemies.is_empty() and not is_spawning:
		wave_cleared.emit(current_wave_index)
		start_next_wave()
