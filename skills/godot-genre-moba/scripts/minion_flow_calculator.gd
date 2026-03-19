# minion_flow_calculator.gd
extends Node
class_name MinionFlowCalculator

# Offloading Heavy Parallel Computations
# Uses WorkerThreadPool to process minion intelligence/paths without lag spikes.

func process_minion_batch(minions: Array[Node]) -> void:
    if minions.is_empty(): return
    
    # Pattern: Distribute logic across all available CPU cores.
    var task_id := WorkerThreadPool.add_group_task(_compute_minion_logic.bind(minions), minions.size())
    
    # Wait for the batch to finish before moving to the next frame step.
    WorkerThreadPool.wait_for_group_task_completion(task_id)

func _compute_minion_logic(index: int, minion_list: Array[Node]) -> void:
    var minion = minion_list[index]
    # Perform expensive path or visibility calculations here.
    # Note: Must only access thread-safe data within this function.
    pass
