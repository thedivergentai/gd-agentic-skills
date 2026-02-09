# skills/genre-horror/scripts/director_pacing.gd
extends Node

## Director Pacing System (Expert Pattern)
## Manages game pacing using a "Sawtooth" tension wave.
## Prevents player exhaustion by enforcing relief periods after peaks.

class_name DirectorPacing

enum TensionState { BUILDUP, PEAK, RELIEF, QUIET }

signal tension_changed(value: float, state: TensionState)
signal event_triggered(event_name: String)

@export var buildup_rate: float = 0.5   # Tension added per second normally
@export var relief_rate: float = 2.0    # Tension removed per second in relief
@export var peak_threshold: float = 75.0
@export var relief_duration: float = 20.0 # Min seconds of claim

var current_tension: float = 0.0
var current_state: TensionState = TensionState.QUIET
var relief_timer: float = 0.0

func _process(delta: float) -> void:
    match current_state:
        TensionState.QUIET:
            # Low level background tension
            _modulate_tension(buildup_rate * 0.2 * delta)
            if current_tension > 25.0:
                 current_state = TensionState.BUILDUP
                 
        TensionState.BUILDUP:
            _modulate_tension(buildup_rate * delta)
            if current_tension > peak_threshold:
                _trigger_peak_event()
                
        TensionState.PEAK:
            # Tension stays high until player resolves threat or escapes
            # Handled by external events calling 'enter_relief()'
            pass
            
        TensionState.RELIEF:
            _modulate_tension(-relief_rate * delta)
            relief_timer -= delta
            if relief_timer <= 0 and current_tension < 10.0:
                 current_state = TensionState.QUIET

func _modulate_tension(amount: float) -> void:
    current_tension = clamp(current_tension + amount, 0.0, 100.0)
    tension_changed.emit(current_tension, current_state)

func _trigger_peak_event() -> void:
    current_state = TensionState.PEAK
    event_triggered.emit("monster_spawn")
    # In a real game, this would query a database of available events

func enter_relief() -> void:
    current_state = TensionState.RELIEF
    relief_timer = relief_duration
    event_triggered.emit("music_calm")

func add_stress(amount: float) -> void:
    # Called by game events (e.g. seeing a corpse)
    current_tension += amount
    if current_state != TensionState.RELIEF:
         if current_tension > peak_threshold and current_state != TensionState.PEAK:
             _trigger_peak_event()

## EXPERT USAGE:
## Autoload this script. Connect to music/lighting systems.
## Call add_stress() from gameplay triggers.
