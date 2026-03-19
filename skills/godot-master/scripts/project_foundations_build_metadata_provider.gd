class_name BuildMetadataProvider
extends RefCounted

## Native extraction of project version and build metadata.
## Useful for display in HUD, settings, or for log signatures.

static func get_version_string() -> String:
	var version = ProjectSettings.get_setting("application/config/version", "0.0.1")
	var build_tag = "DEBUG" if OS.is_debug_build() else "RELEASE"
	
	# Attempt to get platform suffix
	var platform = OS.get_name()
	
	return "v%s-%s [%s]" % [version, build_tag, platform]

static func get_project_name() -> String:
	return ProjectSettings.get_setting("application/config/name", "Godot Project")

static func is_production() -> bool:
	return not OS.is_debug_build() and not Engine.is_editor_hint()

## Custom metadata can be injected during export via CLI --version-hash
static func get_custom_metadata(key: String, default: Variant = null) -> Variant:
	return ProjectSettings.get_setting("metadata/" + key, default)
