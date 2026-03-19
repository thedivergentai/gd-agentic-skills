# multi_threaded_chunk_gen.gd
# Offloading heavy proc-gen tasks to WorkerThreadPool
extends Node

# EXPERT NOTE: Procedural generation creates 'frame-time spikes'. 
# Offloading to a thread prevents the game from freezing.

func request_chunk(chunk_pos: Vector2i):
	WorkerThreadPool.add_task(_generate_chunk_task.bind(chunk_pos))

func _generate_chunk_task(pos: Vector2i):
	# Heavy noise calculations here
	var data = _calc_data(pos)
	
	# Pass data back to main thread for node instantiation
	call_deferred("_finalize_chunk", pos, data)

func _calc_data(_pos): return []
func _finalize_chunk(_pos, _data): pass
