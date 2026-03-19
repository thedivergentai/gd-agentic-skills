# performance_benchmark_runner.gd
# Measuring execution time exactly
extends Node

# EXPERT NOTE: Benchmarking in Godot should use 
# Time.get_ticks_usec() for microsecond precision.

func benchmark_loop_performance():
	var start = Time.get_ticks_usec()
	
	for i in 1000000:
		var x = i * i
		
	var duration = Time.get_ticks_usec() - start
	print("Execution took: ", duration, " microseconds")
