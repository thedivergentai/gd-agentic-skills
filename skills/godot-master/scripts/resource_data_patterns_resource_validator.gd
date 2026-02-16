# godot-master/scripts/resource_data_patterns_resource_validator.gd
@tool
extends EditorScript

## Resource Validator Expert Pattern
## Validates Resource files for missing exports and type safety.

func _run() -> void:
	print("=== Resource Validator ===")
	var issues: Array[Dictionary] = []
	
	_scan_resources("res://", issues)
	
	if issues.is_empty():
		print("✓ All resources are properly configured!")
	else:
		_print_issues(issues)

func _scan_resources(path: String, issues: Array[Dictionary]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var full_path := path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with("."
) and file_name != "addons":
				_scan_resources(full_path + "/", issues)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			_validate_resource(full_path, issues)
			
		file_name = dir.get_next()

func _validate_resource(resource_path: String, issues: Array[Dictionary]) -> void:
	var resource := load(resource_path)
	if not resource:
		issues.append({
			"file": resource_path,
			"type": "load_failed",
			"message": "Failed to load resource"
		})
		return
		
	var script := resource.get_script()
	if not script:
		return  # Built-in resource
		
	var property_list := resource.get_property_list()
	
	for prop in property_list:
		# Check for unset required exports
		if prop["usage"] & PROPERTY_USAGE_EDITOR:
			var value = resource.get(prop["name"])
			if value == null or (value is String and value.is_empty()):
				issues.append({
					"file": resource_path,
					"type": "missing_export",
					"property": prop["name"],
					"message": "Property '%s' is not set" % prop["name"]
				})

func _print_issues(issues: Array[Dictionary]) -> void:
	print("\n❌ Found %d issues:" % issues.size())
	for issue in issues:
		print("  %s: %s" % [issue["file"], issue["message"]])

## EXPERT NOTE:
## Run before building to catch missing resource data.
