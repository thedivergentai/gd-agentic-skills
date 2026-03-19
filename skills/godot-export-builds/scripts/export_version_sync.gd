@tool
extends EditorScript

## Expert Version Syncing.
## Pulls latest Git tag/hash and injects it into 'project.godot'.

func _run() -> void:
	var output = []
	var exit_code = OS.execute("git", ["describe", "--always", "--tags"], output)
	
	if exit_code == 0:
		var version_str = output[0].strip_edges()
		ProjectSettings.set_setting("application/config/version", version_str)
		ProjectSettings.save()
		print("Project version synced to Git: ", version_str)
	else:
		printerr("Git sync failed. Ensure 'git' is in the system PATH.")

## Rule: Automate versioning during export to ensure build traceability.
