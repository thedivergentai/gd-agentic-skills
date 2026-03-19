@tool
extends EditorScript

## Expert Build Size Analyzer.
## Scans resources and identifies the largest contributors to build size.

func _run() -> void:
	var files = _get_all_files("res://")
	var sorted_files = []
	
	for f in files:
		var size = FileAccess.get_file_size(f)
		sorted_files.append({"path": f, "size": size})
		
	sorted_files.sort_custom(func(a, b): return a.size > b.size)
	
	print("--- Top 20 Largest Resources ---")
	for i in range(min(20, sorted_files.size())):
		var f = sorted_files[i]
		print("%s: %.2f MB" % [f.path, f.size / 1024.0 / 1024.0])

func _get_all_files(path: String) -> Array:
	var arr = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				arr.append_array(_get_all_files(path + file_name + "/"))
			else:
				arr.append(path + file_name)
			file_name = dir.get_next()
	return arr
