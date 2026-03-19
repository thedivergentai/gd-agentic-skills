# orphan_node_detector.gd
# Tracking nodes that were removed but never freed
extends Node

# EXPERT NOTE: OBJECT_ORPHAN_NODE_COUNT only works in debug builds.
# Use print_orphan_nodes() to dump the IDs for leak analysis.

func check_for_leaks():
	if not OS.is_debug_build(): return
	
	var orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	if orphans > 0:
		print_rich("[color=red]Memory Leak: %d Orphan nodes detected![/color]" % orphans)
		Node.print_orphan_nodes()
