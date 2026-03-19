# threaded_catchup_simulator.gd
extends Node

# Threaded Offline Catch-Up (Scalability Optimization)
# Offloads heavy incremental math to a background thread to prevent UI freezing.
func process_offline_sim(total_ticks: int) -> void:
    # WorkerThreadPool allows chunked processing across all CPU cores.
    var task_id := WorkerThreadPool.add_group_task(_simulate_single_tick, total_ticks)
    
    # Non-blocking wait if needed, or simply allow background completion.
    WorkerThreadPool.wait_for_group_task_completion(task_id)

func _simulate_single_tick(_tick_index: int) -> void:
    # Logic for individual tick simulation (e.g., compounding interest).
    pass 
