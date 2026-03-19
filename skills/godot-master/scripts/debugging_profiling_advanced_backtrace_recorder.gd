# advanced_backtrace_recorder.gd
# Capturing the call stack with local variables
extends Node

# EXPERT NOTE: capture_script_backtraces(true) is expensive;
# it captures local variable states which blocks deallocation.

func generate_detailed_report():
	var backtraces := Engine.capture_script_backtraces(true)
	for frame in backtraces:
		var file := frame.get_frame_file(0)
		var line := frame.get_frame_line(0)
		var func_name := frame.get_frame_function(0)
		print("Frame: %s:%d in %s" % [file, line, func_name])
