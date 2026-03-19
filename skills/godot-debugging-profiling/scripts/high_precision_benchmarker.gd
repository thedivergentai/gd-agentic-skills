# high_precision_benchmarker.gd
# Measuring execution time with microsecond precision
extends Node

# EXPERT NOTE: Milliseconds lack the precision for microbenchmarking;
# always use Time.get_ticks_usec() for CPU cycle measurements.

func benchmark_operation(callable: Callable):
	var begin := Time.get_ticks_usec()
	callable.call()
	var end := Time.get_ticks_usec()
	print("Operation took %d microseconds" % (end - begin))
