# skills/signal-architecture/code/global_event_bus.gd
extends Node

## Signal Architecture Expert Pattern
## Implements a Namespaced Global Event Bus.

# 1. Namespaced Signal Groups
# Professional pattern: Group signals by domain (UI, Game, System).
class UI_Signals:
    signal menu_opened(menu_name: String)
    signal button_clicked(id: String)
    signal alert_triggered(text: String)

class Game_Signals:
    signal entity_spawned(entity: Node)
    signal player_died(position: Vector3)
    signal world_reset_started

# Instantiate the groups
var UI = UI_Signals.new()
var Game = Game_Signals.new()

# 2. Cross-Frame Stability (CONNECT_DEFERRED)
# Expert logic: Use deferred connections for dangerous scene changes.
func trigger_safe_world_reset() -> void:
    # Logic: If this signal triggers a scene load, deferred ensures 
    # it happens after the current frame processing completes.
    Game.world_reset_started.emit()

func connect_heavy_listener(target: Object, method: String) -> void:
    # Pattern for connecting transient or complex listeners safely.
    Game.entity_spawned.connect(Callable(target, method), CONNECT_DEFERRED)

## EXPERT NOTE:
## Use 'Signal Up, Call Down': Nodes should NEVER 'get_parent()'. 
## They emit signals that parents (or the Event Bus) listen to.
## For 'signal-architecture', use 'Typed Signal Parameters': 
## 'signal damaged(amount: int, source: Node)' to eliminate 
## runtime type bugs and improve IDE autocomplete.
## Use 'Ref-Counted Connections': Transient objects should 
## disconnect in their '_exit_tree()' to prevent memory leaks 
## and 'Object is freed' errors.
## NEVER allow UI nodes to modify Game State directly; they 
## should emit a signal, and a Controller should handle the logic.
