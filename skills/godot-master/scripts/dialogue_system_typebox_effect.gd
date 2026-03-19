# typebox_effect.gd
# Character-by-character text reveal
extends Label

@export var chars_per_second: float = 30.0

func display_text(new_text: String):
	text = new_text
	visible_ratio = 0.0
	var duration = new_text.length() / chars_per_second
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, duration)
