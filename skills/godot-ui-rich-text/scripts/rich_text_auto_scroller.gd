class_name RichTextAutoScroller
extends RichTextLabel

## Expert Vertical Auto-Scroll (Credits/Logs).
## Automatically advances the scroll bar smoothly.

@export var scroll_speed: float = 30.0 # Pixels per second
@export var pause_on_hover: bool = true

func _process(delta: float) -> void:
	if pause_on_hover and get_global_rect().has_point(get_global_mouse_position()):
		return
		
	var v_scroll = get_v_scroll_bar()
	v_scroll.value += scroll_speed * delta
	
	if v_scroll.value >= v_scroll.max_value - v_scroll.page:
		# Optionally loop or stop
		pass
