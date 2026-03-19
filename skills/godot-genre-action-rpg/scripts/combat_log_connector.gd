# combat_log_connector.gd
extends Node
class_name CombatLogConnector

# Signal-Driven Combat Log (Dependency Injection)
# Connects combat events to UI/Logging systems without hardcoding references.

func connect_entity(entity: Node) -> void:
    # Pattern: Bind metadata like entity name to the signal callback.
    if entity.has_signal(&"health_changed"):
        entity.health_changed.connect(_on_health_update.bind(entity.name))

func _on_health_update(new_val: int, entity_name: String) -> void:
    # Centralized event handling (e.g., adding to a UI RichTextLabel).
    print("[Combat] ", entity_name, " health updated to: ", new_val)
