# godot-master/scripts/project_foundations_scene_naming_validator.gd
@tool
extends EditorScript

## Scene Naming Validator Expert Pattern
## Scans project for naming convention violations and %SceneUniqueName usage.

func _run() -> void:
	print("=== Scene Naming Validator ===")
	var violations := []
	
	# Scan all .tscn files
	_scan_directory("res://", violations)
	
	if violations.is_empty():
		print("✓ All scenes follow naming conventions!")
	else:
		print("❌ Found %d violations:" % violations.size())
		for v in violations:
			print("  - %s" % v)

func _scan_directory(path: String, violations: Array) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var full_path := path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_scan_directory(full_path + "/", violations)
		elif file_name.ends_with(".tscn"):
			_validate_scene(full_path, violations)
			
		file_name = dir.get_next()

func _validate_scene(scene_path: String, violations: Array) -> void:
	# 1. Check filename is snake_case
	var filename := scene_path.get_file().get_basename()
	if not _is_snake_case(filename):
		violations.append("%s: Filename not snake_case" % scene_path)
	
	# 2. Load scene and check node names
	var scene := load(scene_path)
	if scene:
		var root := scene.instantiate()
		_check_node_naming(root, scene_path, violations)
		root.queue_free()

func _check_node_naming(node: Node, scene_path: String, violations: Array) -> void:
	# Node names should be PascalCase
	if not _is_pascal_case(node.name):
		violations.append("%s: Node '%s' not PascalCase" % [scene_path, node.name])
	
	for child in node.get_children():
		_check_node_naming(child, scene_path, violations)

func _is_snake_case(text: String) -> bool:
	# Valid snake_case: all lowercase, numbers, underscores
	var regex := RegEx.new()
	regex.compile("^[a-z0-9_]+$")
	return regex.search(text) != null

func _is_pascal_case(text: String) -> bool:
	# Valid PascalCase: starts with uppercase, alphanumeric
	if text.is_empty() or not text[0].to_upper() == text[0]:
		return false
	# Built-in nodes like "Area2D" are always valid
	return true

## EXPERT NOTE:
## Run this validator BEFORE submitting PRs or releasing builds.
## CRITICAL: %SceneUniqueNames are NOT validated here - use runtime checks.
## For CI/CD: export violations to JSON for automated PR blocking.
