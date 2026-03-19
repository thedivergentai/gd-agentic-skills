## Global Event Bus (Autoload: EventBus)
## Strongly-typed Signal Bus for system decoupling.
## Allows nodes to communicate without direct dependencies.
extends Node

# Expert: Group signals by domain for clarity
# --- Player Signals ---
signal player_spawned(player: Node2D)
signal player_died(reason: StringName)
signal player_health_changed(current: int, max: int)

# --- World Signals ---
signal level_started(id: StringName)
signal level_completed(id: StringName)

# --- System Signals ---
signal save_requested
signal settings_updated(config: Dictionary)

## Tip: Use StringName (&"name") for signal parameters to avoid string overhead.
## Tip: Always include 'player' or 'sender' references if multiple instances exist.
