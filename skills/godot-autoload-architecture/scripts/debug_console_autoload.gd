# debug_console_autoload.gd
# Universal debug overlay accessible from any scene
extends CanvasLayer

# EXPERT NOTE: UI Autoloads should use CanvasLayer to ensure they 
# always draw on top of game scenes.

@onready var label = $Label

func _ready():
	process_mode = PROCESS_MODE_ALWAYS # Console works even when paused

func log_message(msg: String):
	label.text += "\n" + msg
	print("[Debug] ", msg)
