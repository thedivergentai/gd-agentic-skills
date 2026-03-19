# skills/genre-simulation/scripts/sim_tick_manager.gd
extends Node

## Sim Tick Manager (Expert Pattern)
## Centralized time management for simulation games.
## Decouples game logic from frame rate (delta) for deterministic speed control.

class_name SimTickManager

signal tick(day: int, hour: int)
signal speed_changed(new_speed: int)

enum Speed { PAUSED = 0, NORMAL = 1, FAST = 2, SUPER_FAST = 5 }

var current_speed: int = Speed.NORMAL
var _accumulated_time: float = 0.0
const SECONDS_PER_GAME_HOUR: float = 2.0 # 2 real seconds = 1 game hour

var game_hour: int = 8
var game_day: int = 1

func _process(delta: float) -> void:
    if current_speed == Speed.PAUSED:
        return
        
    _accumulated_time += delta * current_speed
    
    while _accumulated_time >= SECONDS_PER_GAME_HOUR:
        _accumulated_time -= SECONDS_PER_GAME_HOUR
        _advance_hour()

func _advance_hour() -> void:
    game_hour += 1
    if game_hour >= 24:
        game_hour = 0
        game_day += 1
        
    tick.emit(game_day, game_hour)
    # Batch processing for economy/entities would happen here
    # get_tree().call_group("tick_listeners", "on_tick", game_day, game_hour)

func set_speed(speed: int) -> void:
    current_speed = speed
    speed_changed.emit(current_speed)

func pause() -> void:
    set_speed(Speed.PAUSED)

## EXPERT USAGE:
## Connect Economy and AI systems to 'tick' signal. 
## NEVER use _process for simulation logic, always use this tick.
