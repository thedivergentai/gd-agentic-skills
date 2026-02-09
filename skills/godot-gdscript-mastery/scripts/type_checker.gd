# skills/gdscript-mastery/scripts/type_checker.gd
@tool
extends EditorScript

## Type Checker Expert Pattern
## Scans codebase for missing type hints and static typing violations.

func _run() -> void:
	print("=== GDScript Type Checker ===")
	var violations: Array[Dictionary] = []
	
	_scan_directory("res://", violations)
	
	if violations.is_empty():
		print("✓ All scripts use proper static typing!")
	else:
		print("❌ Found %d type violations:" % violations.size())
		_print_violations(violations)

func _scan_directory(path: String, violations: Array[Dictionary]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var full_path := path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with(".") and file_name != "addons":
				_scan_directory(full_path + "/", violations)
		elif file_name.ends_with(".gd") and not file_name.begins_with("."):
			_check_script(full_path, violations)
			
		file_name = dir.get_next()

func _check_script(script_path: String, violations: Array[Dictionary]) -> void:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
		
	var line_number := 0
	while not file.eof_reached():
		line_number += 1
		var line := file.get_line()
		
		# Check for untyped variables
		if _has_untyped_var(line):
			violations.append({
				"file": script_path,
				"line": line_number,
				"type": "untyped_variable",
				"content": line.strip_edges()
			})
		
		# Check for untyped function returns
		if _has_untyped_function(line):
			violations.append({
				"file": script_path,
				"line": line_number,
				"type": "untyped_function",
				"content": line.strip_edges()
			})
		
		# Check for untyped parameters
		if _has_untyped_params(line):
			violations.append({
				"file": script_path,
				"line": line_number,
				"type": "untyped_parameters",
				"content": line.strip_edges()
			})

func _has_untyped_var(line: String) -> bool:
	# Match: var x = ...  (without type hint)
	# Don't match: var x: int = ... or var x := ...
	var regex := RegEx.new()
	regex.compile("^\\s*var\\s+\\w+\\s*=\\s*(?!.*:)")
	return regex.search(line) != null and ":=" not in line

func _has_untyped_function(line: String) -> bool:
	# Match: func name(...) without -> type
	if not line.begins_with("func "):
		return false
	return "->" not in line and ":" in line  # Has params but no return type

func _has_untyped_params(line: String) -> bool:
	# Match function with parameters but without type hints
	var regex := RegEx.new()
	regex.compile("func\\s+\\w+\\(.*\\w+[^:,\\)].*\\)")
	return regex.search(line) != null

func _print_violations(violations: Array[Dictionary]) -> void:
	var grouped := {}
	for v in violations:
		if v["file"] not in grouped:
			grouped[v["file"]] = []
		grouped[v["file"]].append(v)
	
	for file in grouped:
		print("\n📄 %s:" % file)
		for v in grouped[file]:
			print("  Line %d [%s]: %s" % [v["line"], v["type"], v["content"]])

## EXPERT NOTE:
## Enable UNTYPED_DECLARATION warning in Project Settings for real-time checks.
## This script is for batch auditing before releases.
## CRITICAL: 20-40% performance gain with full static typing in hot paths.
