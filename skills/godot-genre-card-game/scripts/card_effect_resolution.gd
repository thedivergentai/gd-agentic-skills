# skills/genre-card-game/scripts/card_effect_resolution.gd
extends Node

## Card Effect Resolution (Expert Pattern)
## Implements a Command Pattern / Stack for resolving card effects.
## Allows for complex chains, counter-play, and sequential animations.

class_name CardEffectResolution

signal effect_started(effect: CardEffect)
signal effect_finished(effect: CardEffect)
signal queue_empty

var effect_queue: Array[CardEffect] = []
var is_resolving: bool = false

# Inner class or external resource for Effect
class CardEffect:
    var source_card: Resource
    var target: Node
    var type: String # DAMAGE, HEAL, DRAW
    var value: int
    
    func execute() -> void:
        # Override this in subclasses
        pass

func add_effect(effect: CardEffect) -> void:
    effect_queue.append(effect)
    if not is_resolving:
        _resolve_next()

func _resolve_next() -> void:
    if effect_queue.is_empty():
        is_resolving = false
        queue_empty.emit()
        return

    is_resolving = true
    var effect = effect_queue.pop_front() # BFS or FIFO. Use pop_back for LIFO (Stack)
    
    effect_started.emit(effect)
    
    # Execute logic
    await _execute_effect_logic(effect)
    
    effect_finished.emit(effect)
    
    # Recursive next
    _resolve_next()

func _execute_effect_logic(effect: CardEffect) -> void:
    # In a full system, this would call effect.execute()
    # Here we simulate with a match or generic handler
    print("Resolving Effect: %s on %s" % [effect.type, effect.target])
    
    match effect.type:
        "DAMAGE":
            if effect.target.has_method("take_damage"):
                effect.target.take_damage(effect.value)
        "HEAL":
             if effect.target.has_method("heal"):
                effect.target.heal(effect.value)
    
    # Fake animation delay
    await get_tree().create_timer(0.5).timeout

## EXPERT USAGE:
## When playing a card, instantiate CardEffect and pass to add_effect().
## Listen to signals to block UI during resolution.
