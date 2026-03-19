class_name ExportFeatureFlagManager
extends Node

## Expert runtime Feature Flag management.
## Swaps logic/API endpoints based on build features.

func is_debug() -> bool:
	return OS.has_feature("debug")

func is_release() -> bool:
	return OS.has_feature("release")

func is_mobile() -> bool:
	return OS.has_feature("mobile")

func get_api_endpoint() -> String:
	if is_debug():
		return "https://dev.api.game.com"
	return "https://api.game.com"

## Rule: Never hardcode 'is_debug' flags. Rely on Godot's built-in feature flags.
