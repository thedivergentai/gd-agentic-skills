# skills/autoload-architecture/code/stateless_bus.gd
extends Node

## Stateless Signal Bus Expert Pattern
## Optimized for decoupling and lazy-loading of systems.

# 1. Defined Semantic Signals
# Avoid 'generic' signals. Be specific about the domain.
signal player_health_changed(new_health: int, max_health: int)
signal level_completed(id: String, score: int)
signal system_booted(id: String)

func _ready() -> void:
    # 2. Boot-time Priorities
    # Autoloads initialize in order. Use signals to notify
    # other singletons that this generic hub is ready.
    system_booted.emit("StatelessBus")

func notify_health(h: int, m: int) -> void:
    player_health_changed.emit(h, m)

## EXPERT NOTE:
## NEVER store state (e.g. current_health) in the Signal Bus.
## The bus is a 'Post Office' - it delivers messages (Signals),
## it does not store packages (State). 
