# stack_trace_logger.gd
# Capturing the execution path on failure
extends Node

# EXPERT NOTE: get_stack() provides a programmatic 
# check of where a logic error originated.

func log_problem(msg: String):
	var stack = get_stack()
	printerr("PROBLEM: ", msg)
	for frame in stack:
		printerr(" -> ", frame.source, ":", frame.line, " in ", frame.function)
