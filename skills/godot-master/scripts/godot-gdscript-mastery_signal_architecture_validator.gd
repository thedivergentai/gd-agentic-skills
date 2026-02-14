# skills/gdscript-mastery/scripts/signal_architecture_validator.gd
@tool
extends EditorScript

## Signal Architecture Validator Expert Pattern
## Enforces "Signal Up, Call Down" pattern - detects parent method calls from children.

func _run() -> void:
	print("=== Signal Architecture Validator ===")
	var violations: Array[Dictionary] = []
	
	_scan_directory("res://", violations)
	
	if violations.is_empty():
		print("✓ Signal architecture follows best practices!")
	else:
		print("⚠️ Found %d potential violations:" % violations.size())
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
		elif file_name.ends_with(".gd"):
			_check_signal_architecture(full_path, violations)
			
		file_name = dir.get_next()

func _check_signal_architecture(script_path: String, violations: Array[Dictionary]) -> void:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
		
	var content := file.get_as_text()
	var lines := content.split("\n")
	
	for i in range(lines.size()):
		var line := lines[i]
		
		# Check for get_parent() calls (code smell)
		if "get_parent()" in line and not line.strip_edges().begins_with("#"):
			violations.append({
				"file": script_path,
				"line": i + 1,
				"type": "get_parent_call",
				"severity": "HIGH",
				"message": "get_parent() is a code smell - use signals to communicate up",
				"content": line.strip_edges()
			})
		
		# Check for owner. method calls (potential violation)
		if "owner." in line and ("(" in line) and not line.strip_edges().begins_with("#"):
			violations.append({
				"file": script_path,
				"line": i + 1,
				"type": "owner_method_call",
				"severity": "MEDIUM",
				"message": "Calling owner methods - consider using signals instead",
				"content": line.strip_edges()
			})
		
		# Check for untyped signal definitions
		if line.strip_edges().begins_with("signal ") and "(" not in line:
			violations.append({
				"file": script_path,
				"line": i + 1,
				"type": "untyped_signal",
				"severity": "LOW",
				"message": "Signal without typed parameters - add type hints",
				"content": line.strip_edges()
			})

func _print_violations(violations: Array[Dictionary]) -> void:
	var by_severity := {"HIGH": [], "MEDIUM": [], "LOW": []}
	
	for v in violations:
		by_severity[v["severity"]].append(v)
	
	for severity in ["HIGH", "MEDIUM", "LOW"]:
		var items: Array = by_severity[severity]
		if items.is_empty():
			continue
			
		var icon := "🔴" if severity == "HIGH" else ("🟡" if severity == "MEDIUM" else "🟢")
		print("\n%s %s Severity (%d):" % [icon, severity, items.size()])
		
		for v in items:
			print("  %s:%d [%s]" % [v["file"], v["line"], v["type"]])
			print("    → %s" % v["message"])

## EXPERT NOTE:
## "Signal Up, Call Down" = Children emit signals, Parents call child methods.
## ANTI-PATTERN: get_parent().some_method() - tight coupling, breaks reusability.
## CORRECT: emit signal, let parent decide how to handle it.
## Example: 
##   Child: signal health_depleted()
##   Parent: child.health_depleted.connect(_on_child_died)
