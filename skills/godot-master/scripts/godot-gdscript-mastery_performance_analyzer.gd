# skills/gdscript-mastery/scripts/performance_analyzer.gd
@tool
extends EditorScript

## Performance Analyzer Expert Pattern
## Detects common GDScript performance anti-patterns.

const PERFORMANCE_KILLERS := {
	"get_node": {
		"pattern": "get_node\\(.*\\)",
		"message": "get_node() in hot path - cache with @onready",
		"severity": "HIGH"
	},
	"$_access": {
		"pattern": "\\$\\w+",
		"message": "$ node access in loop - cache in @onready var",
		"severity": "MEDIUM"
	},
	"dynamic_dict": {
		"pattern": "\\w+\\[\"\\w+\"\\]",
		"message": "Direct dict access - use .get(key, default) for safety",
		"severity": "MEDIUM"
	},
	"string_concat": {
		"pattern": "\\w+\\s*\\+\\s*\"",
		"message": "String concatenation in loop - use Array.join() or format strings",
		"severity": "LOW"
	}
}

func _run() -> void:
	print("=== Performance Analyzer ===")
	var issues: Array[Dictionary] = []
	
	_scan_directory("res://", issues)
	
	if issues.is_empty():
		print("✓ No obvious performance issues detected!")
	else:
		_print_issues(issues)

func _scan_directory(path: String, issues: Array[Dictionary]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var full_path := path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with(".") and file_name != "addons":
				_scan_directory(full_path + "/", issues)
		elif file_name.ends_with(".gd"):
			_analyze_script(full_path, issues)
			
		file_name = dir.get_next()

func _analyze_script(script_path: String, issues: Array[Dictionary]) -> void:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
		
	var line_number := 0
	var in_process_loop := false
	
	while not file.eof_reached():
		line_number += 1
		var line := file.get_line()
		
		# Track if we're in _process or _physics_process
		if "_process(" in line or "_physics_process(" in line:
			in_process_loop = true
		
		if in_process_loop:
			for killer_name in PERFORMANCE_KILLERS:
				var killer: Dictionary = PERFORMANCE_KILLERS[killer_name]
				var regex := RegEx.new()
				regex.compile(killer["pattern"])
				
				if regex.search(line):
					issues.append({
						"file": script_path,
						"line": line_number,
						"severity": killer["severity"],
						"message": killer["message"],
						"content": line.strip_edges()
					})

func _print_issues(issues: Array[Dictionary]) -> void:
	# Group by severity
	var high: Array[Dictionary] = []
	var medium: Array[Dictionary] = []
	var low: Array[Dictionary] = []
	
	for issue in issues:
		match issue["severity"]:
			"HIGH": high.append(issue)
			"MEDIUM": medium.append(issue)
			"LOW": low.append(issue)
	
	if not high.is_empty():
		print("\n🔴 HIGH Severity Issues (%d):" % high.size())
		for issue in high:
			print("  %s:%d - %s" % [issue["file"], issue["line"], issue["message"]])
	
	if not medium.is_empty():
		print("\n🟡 MEDIUM Severity Issues (%d):" % medium.size())
		for issue in medium:
			print("  %s:%d - %s" % [issue["file"], issue["line"], issue["message"]])
	
	if not low.is_empty():
		print("\n🟢 LOW Severity Issues (%d):" % low.size())

## EXPERT NOTE:
## Run this before optimizing performance bottlenecks.
## CRITICAL: get_node() in _process() = 10-100x slower than cached @onready.
## String concatenation in loops = GC pressure, use %s formatting instead.
