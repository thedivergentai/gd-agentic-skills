# threaded_inventory_loader.gd
extends Node
class_name ThreadedInventoryLoader

# Threaded Inventory Parser
# Offloads parsing thousands of persistent items to worker threads to maintain 60FPS.

var _item_pool: Array[Dictionary] = []

func process_inventory(raw_json_items: Array[Dictionary]) -> void:
    _item_pool = raw_json_items
    
    # Pattern: Use WorkerThreadPool to distribute the dataset across all cores.
    var task_id := WorkerThreadPool.add_group_task(_parse_single_item, _item_pool.size())
    
    # Optional: Wait if completion is required before closing the loading screen.
    WorkerThreadPool.wait_for_group_task_completion(task_id)

func _parse_single_item(index: int) -> void:
    var item_data = _item_pool[index]
    # Handle heavy logic: Resource loading, Icon generation, or dynamic stats.
    pass
