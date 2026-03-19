class_name RichTextImageScaler
extends Node

## Expert BBCode Image Scaling Helper.
## Ensures [img] tags match the current font size dynamically.

static func get_styled_img(rtl: RichTextLabel, path: String) -> String:
	# Get standard font size from theme
	var font_size = rtl.get_theme_font_size("normal_font_size")
	if font_size <= 0: font_size = 16
	
	# valign=center is crucial for alignment
	return "[img width=%d valign=center]%s[/img]" % [font_size, path]
