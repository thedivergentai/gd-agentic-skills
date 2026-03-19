@tool
extends EditorExportPlugin

## Expert Post-Export Hook.
## Automates tasks like zipping or cleaning up files after a build finishes.

func _get_name() -> String:
	return "ExportPostProcessor"

func _export_end() -> void:
	# Note: Use OS.execute to trigger external zip tools or manifest generators.
	var build_path = get_option("export_path")
	print("Post-processing build at: ", build_path)
	
	# Logic to Zip files or notify Deployment Slack here...
	pass

## Rule: Use EditorExportPlugin to unify export workflows for all team members.
