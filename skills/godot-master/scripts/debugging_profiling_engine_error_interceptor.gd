# engine_error_interceptor.gd
# Piping C++ engine errors to custom logging backends
extends Node

# EXPERT NOTE: register_message_capture allows you to intercept
# underlying engine errors that usually only go to the console.

func _ready():
	if OS.is_debug_build():
		EngineDebugger.register_message_capture("custom_logger", _on_engine_error)

func _on_engine_error(message: String, data: Array) -> bool:
	# Process or send error data to external analytics
	print_rich("[color=orange]Intercepted Engine Error:[/color] ", message)
	return true
