class_name ExportPCKPatchLoader
extends Node

## Expert PCK Patching/DLC Loader.
## Downloads and mounts external .pck files at runtime.

const PATCH_URL = "https://cdn.game.com/updates/patch_v1.pck"
const LOCAL_PATH = "user://patch_v1.pck"

func load_patch() -> void:
	# Assume file is already downloaded via HTTPRequest
	if FileAccess.file_exists(LOCAL_PATH):
		var success = ProjectSettings.load_resource_pack(LOCAL_PATH)
		if success:
			print("PCK Patch loaded successfully!")
		else:
			printerr("Failed to load PCK archive.")

## Tip: Use this for DLC, localized assets, or fixing bugs without full app updates.
