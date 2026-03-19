class_name RichTextHoverReactive
extends RichTextLabel

## Expert Mouse-Reactive Text Spans.
## Triggers sound and cursor changes when hovering over [url].

@export var hover_sfx: AudioStream

func _ready() -> void:
	meta_hover_started.connect(_on_hover_in)
	meta_hover_ended.connect(_on_hover_out)

func _on_hover_in(_meta: Variant) -> void:
	if hover_sfx:
		var p := AudioStreamPlayer.new()
		p.stream = hover_sfx
		add_child(p)
		p.play()
		p.finished.connect(p.queue_free)
	
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)

func _on_hover_out(_meta: Variant) -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
