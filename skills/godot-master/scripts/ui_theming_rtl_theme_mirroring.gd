# rtl_theme_mirroring.gd
# Handling Right-to-Left (RTL) layout mirroring via Themes [19]
extends MarginContainer

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_TRANSLATION_CHANGED:
		# Detect if the current locale (Arabic, Hebrew) requires RTL
		if is_layout_rtl():
			# Apply mirrored stylebox/font overrides
			var rtl_style := get_theme_stylebox("panel_rtl", "CustomHUD")
			add_theme_stylebox_override("panel", rtl_style)
		else:
			remove_theme_stylebox_override("panel")
