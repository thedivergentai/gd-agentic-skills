# group_weather_broadcaster.gd
extends Node
class_name GroupWeatherBroadcaster

# Global Environment Group Broadcasting
# Decouples weather logic from individual entities using high-speed group calls.

func apply_weather_state(weather_type: StringName) -> void:
    # Pattern: Avoid iterating nodes manually. Use call_group_flags for efficiency.
    get_tree().call_group_flags(
        SceneTree.GROUP_CALL_DEFERRED,
        &"environment_reactors",
        &"_on_weather_update",
        weather_type
    )
