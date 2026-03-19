# high_speed_aggro_broadcaster.gd
extends Node
class_name HighSpeedAggroBroadcaster

# Group Broadcasting for Faction/Aggro
# Alerts a localized faction instantly without nested node iterations.

func alert_faction(faction_id: StringName, threat_pos: Vector3) -> void:
    # Pattern: Use call_group_flags with DEFERRED to avoid re-entering state logic.
    get_tree().call_group_flags(
        SceneTree.GROUP_CALL_DEFERRED,
        faction_id,           # Target Group (e.g. &"guards")
        &"on_threat_detected", # Target Method
        threat_pos            # Arguments
    )
