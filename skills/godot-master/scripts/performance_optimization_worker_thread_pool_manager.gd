# worker_thread_pool_manager.gd
# Offloading heavy computation to worker threads
extends Node

# EXPERT NOTE: WorkerThreadPool is superior to Thread.new() in 
# Godot 4 as it reuses a pool of system threads, avoiding 
# the overhead of spawning new OS threads intermittently.

func process_massive_dataset(data: Array):
	var task_id = WorkerThreadPool.add_task(_do_heavy_work.bind(data))
	# task_id can be used to check completion or wait
	# WorkerThreadPool.is_task_completed(task_id)

func _do_heavy_work(data: Array):
	for i in data:
		# Process locally without touching the SceneTree directly
		pass
