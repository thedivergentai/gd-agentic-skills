# godot-master/scripts/project_foundations_dependency_auditor.gd
@tool
extends EditorScript

## Dependency Auditor Expert Pattern
## Analyzes scene dependencies to detect circular references and coupling issues.

func _run() -> void:
	print("=== Dependency Auditor ===")
	var dependency_map := {}
	
	# Build dependency graph
	_build_dependency_map("res://", dependency_map)
	
	# Detect circular dependencies
	var circular := _detect_circular_deps(dependency_map)
	if not circular.is_empty():
		print("⚠️ Circular dependencies detected:")
		for cycle in circular:
			print("  %s" % cycle)
	
	# Report highly coupled scenes
	_report_coupling(dependency_map)

func _build_dependency_map(path: String, dep_map: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var full_path := path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_build_dependency_map(full_path + "/", dep_map)
		elif file_name.ends_with(".tscn"):
			dep_map[full_path] = _extract_dependencies(full_path)
			
		file_name = dir.get_next()

func _extract_dependencies(scene_path: String) -> Array:
	var deps := []
	var file := FileAccess.open(scene_path, FileAccess.READ)
	if not file:
		return deps
		
	var content := file.get_as_text()
	
	# Parse ext_resource entries
	var regex := RegEx.new()
	regex.compile('ext_resource.*path="([^"]+)"')
	
	for match in regex.search_all(content):
		var resource_path: String = match.get_string(1)
		if resource_path.ends_with(".tscn"):
			deps.append(resource_path)
	
	return deps

func _detect_circular_deps(dep_map: Dictionary) -> Array:
	var circular := []
	
	for scene in dep_map:
		var visited := {}
		var path := []
		if _has_cycle(scene, dep_map, visited, path):
			circular.append(" -> ".join(path))
	
	return circular

func _has_cycle(scene: String, dep_map: Dictionary, visited: Dictionary, path: Array) -> bool:
	if scene in path:
		path.append(scene)
		return true
		
	if visited.get(scene, false):
		return false
		
	visited[scene] = true
	path.append(scene)
	
	for dep in dep_map.get(scene, []):
		if _has_cycle(dep, dep_map, visited, path):
			return true
			
	path.pop_back()
	return false

func _report_coupling(dep_map: Dictionary) -> void:
	# Find scenes with high dependency counts
	print("\n=== Coupling Analysis ===")
	for scene in dep_map:
		var dep_count := dep_map[scene].size()
		if dep_count > 5:
			print("⚠️ High coupling: %s (%d dependencies)" % [scene, dep_count])

## EXPERT NOTE:
## Circular dependencies = runtime loading errors in Godot.
## NEVER structure scenes as: Player -> Weapon -> Player
## FIX: Use Resources for shared data, signals for communication.
## Run this auditor monthly on projects >50 scenes.
