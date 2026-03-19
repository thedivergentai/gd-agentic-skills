# rts_army_manager.gd
extends Node
class_name RTSArmyManager

# High-Performance Multithreaded AI Updates
# Offloads thousands of unit state calculations to background worker threads.

var _units: Array[Node] = []

func _physics_process(_delta: float) -> void:
    if _units.is_empty(): return
    
    # Pattern: Use WorkerThreadPool to distribute heavy AI/Targeting across all cores.
    var task_id := WorkerThreadPool.add_group_task(_process_unit_ai, _units.size())
    
    # IMPORTANT: Wait for completion if subsequent logic (like movement) depends on results.
    WorkerThreadPool.wait_for_group_task_completion(task_id)

func _process_unit_ai(index: int) -> void:
    var unit := _units[index]
    # Execute expensive logic here: Targeting, LOS checks, or state evaluation.
    pass

func register_unit(unit: Node) -> void:
    _units.append(unit)

func unregister_unit(unit: Node) -> void:
    _units.erase(unit)
