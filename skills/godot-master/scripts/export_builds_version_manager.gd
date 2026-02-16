# godot-master/scripts/export_builds_version_manager.gd
extends Node

## Version Manager Expert Pattern
## Handles version injection, build metadata, and display strings.

class_name VersionManager

# Configuration - can be updated by CI/CD scripts
const MAJOR = 1
const MINOR = 0
const PATCH = 0
const STATUS = "dev" # dev, alpha, beta, rc, stable
const BUILD_HASH = "local" # Git hash injected during export

# Computed properties
var version_string: String:
	get: return "%d.%d.%d" % [MAJOR, MINOR, PATCH]

var full_version_string: String:
	get: return "%s-%s (%s)" % [version_string, STATUS, BUILD_HASH]

func _ready() -> void:
	print_verbose("Version Manager Initialized: ", full_version_string)
	_update_window_title()

func _update_window_title() -> void:
	if OS.is_debug_build():
		DisplayServer.window_set_title(
			"%s | DEBUG | %s" % [ProjectSettings.get_setting("application/config/name"), full_version_string]
		)
	else:
		# Optionally keep version in title for non-final builds
		if STATUS != "stable":
			DisplayServer.window_set_title(
				"%s %s" % [ProjectSettings.get_setting("application/config/name"), version_string]
			)

func is_feature_enabled(feature_tag: String) -> bool:
	return OS.has_feature(feature_tag)

## EXPERT USAGE:
## label.text = VersionManager.full_version_string
