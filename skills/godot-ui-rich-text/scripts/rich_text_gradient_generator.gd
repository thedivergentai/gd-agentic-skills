class_name RichTextGradientGenerator
extends RefCounted

## Expert Multi-Stop Gradient BBCode Generator.
## Wraps a string in granular [color] tags to create a smooth gradient.

static func generate(text: String, color_start: Color, color_end: Color) -> String:
	var result := ""
	var length := text.length()
	
	for i in range(length):
		var t := float(i) / float(length - 1) if length > 1 else 0.5
		var col := color_start.lerp(color_end, t)
		result += "[color=#%s]%s[/color]" % [col.to_html(false), text[i]]
		
	return result
