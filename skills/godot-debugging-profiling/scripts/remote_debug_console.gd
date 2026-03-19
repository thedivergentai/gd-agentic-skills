# remote_debug_console.gd
# Real-time command console for mobile/deployed builds
extends CanvasLayer

# EXPERT NOTE: Remote builds don't show the Terminal. 
# A custom UI console allows running commands on-device.

@onready var line_edit = $LineEdit

func _on_text_submitted(cmd: String):
	match cmd:
		"noclip": _toggle_noclip()
		"gold": _add_gold(1000)
	line_edit.clear()

func _toggle_noclip(): pass
func _add_gold(_amt: int): pass
