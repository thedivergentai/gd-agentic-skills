# thread_safety_assert.gd
# Caught threading violations early
extends Node

# EXPERT NOTE: Writing to the SceneTree from a worker 
# thread is a common source of crashes.

func update_main_thread_data():
	# EXPERT: Verifies that this code runs on the Main Thread
	assert(OS.get_main_thread_id() == OS.get_thread_caller_id())
	# Safe to update UI or Nodes now
