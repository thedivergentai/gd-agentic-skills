# pulsating_ui_theme.gd
# Animating Theme properties via Tweens (Requires duplication) [10]
extends PanelContainer

var _tween_style: StyleBoxFlat

func trigger_pulsate() -> void:
	# Duplicate stylebox to ensure only THIS button pulsates
	_tween_style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	add_theme_stylebox_override("panel", _tween_style)
	
	var tween = create_tween().set_loops()
	# Target the resource property directly
	tween.tween_property(_tween_style, "bg_color", Color.RED, 0.4)
	tween.tween_property(_tween_style, "bg_color", Color.BLACK, 0.4)
