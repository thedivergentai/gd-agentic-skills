class_name RichTextBBCodeSanitizer
extends RefCounted

## Expert BBCode Sanitizer.
## Strips potentially malicious or layout-breaking tags from user input.

static func sanitize(input: String, allow_list: Array[String] = ["b", "i", "u", "color"]) -> String:
	var result = input
	var regex = RegEx.new()
	
	# Match any tag starting with [
	regex.compile("\\[/?([a-z0-9_]+)[^\\]]*\\]")
	
	for m in regex.search_all(input):
		var tag_name = m.get_string(1)
		if not allow_list.has(tag_name):
			result = result.replace(m.get_string(), "")
			
	return result
