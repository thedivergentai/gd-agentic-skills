# godot-master/scripts/turn_system_timeline_turn_manager.gd
extends Node

## Turn System Expert Pattern
## Implements Timeline-Based Initiative (CTB) and State Interrupts.

class Combatant:
    var name: String
    var speed: float = 10.0
    var energy: float = 0.0 # Energy accumulates based on speed
    var is_active: bool = true

var _combatants: Array[Combatant] = []
var _current_unit: Combatant = null

# 1. Timeline-Based Initiative
func process_timeline() -> Combatant:
    # Expert logic: Accumulate energy until someone hits the 100 threshold.
    while true:
        for unit in _combatants:
            if not unit.is_active: continue
            
            unit.energy += unit.speed
            if unit.energy >= 100.0:
                unit.energy -= 100.0
                _current_unit = unit
                return unit

# 2. Interruption Mechanics (State Stack Logic)
func inject_interrupt(interrupt_unit: Combatant) -> void:
    # Professional pattern: Temporarily halt the current turn 
    # to process a reaction or counter-attack.
    print("Interrupt! ", interrupt_unit.name, " is reacting.")
    var original_unit = _current_unit
    
    _current_unit = interrupt_unit
    # Process interrupt logic...
    
    _current_unit = original_unit
    print("Resuming turn for ", _current_unit.name)

# 3. Dynamic Turn Prediction
func get_predicted_order(steps: int = 10) -> Array[String]:
    # Professional protocol: Simulate the timeline to show the player 
    # who moves next.
    var prediction = []
    var temp_energy = {}
    for c in _combatants: temp_energy[c] = c.energy
    
    for i in range(steps):
        var next_unit = _simulate_next(temp_energy)
        prediction.append(next_unit.name)
    
    return prediction

func _simulate_next(energy_map: Dictionary) -> Combatant:
    while true:
        for unit in _combatants:
            energy_map[unit] += unit.speed
            if energy_map[unit] >= 100.0:
                energy_map[unit] -= 100.0
                return unit

## EXPERT NOTE:
## Use 'Signal-Based Turn Sync': Emit 'turn_started(unit)' and 
## 'turn_ended(unit)' signals to the UI. The UI should NEVER poll 
## the TurnManager; it only reacts to these signals.
## For 'turn-system', implement 'Asynchronous Sequence Execution': 
## Allow multiple units with identical initiative to perform animations 
## simultaneously to prevent "Turn Lag" in large battles.
## NEVER assume a combatant index will persist; if a unit dies 
## during a round, use 'Combatant.is_active = false' and cleanup 
## the array only at the start of a clear tick.
