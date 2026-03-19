# harvest_loop_patterns.gd
extends Node

# 1. Low Processor Mode Optimization
# EXPERT NOTE: Drastically saves battery on mobile devices for UI-driven gathering games.
func setup_idle_optimization() -> void:
    OS.low_processor_usage_mode = true
    OS.low_processor_usage_mode_sleep_usec = 6900 # ~144 Hz cap for responsiveness

# 2. Calculating Offline Gains (UNIX Time)
# EXPERT NOTE: Evaluates real-world seconds passed since the player last saved.
func get_offline_ticks(last_save_time_unix: int) -> int:
    var current_time := int(Time.get_unix_time_from_system())
    return current_time - last_save_time_unix

# 3. Threaded Resource Batch Calculations
# EXPERT NOTE: Offloads heavy math over thousands of elements to background CPU cores.
func process_harvest_batch(data_array: Array) -> void:
    WorkerThreadPool.add_group_task(_compute_yield, data_array.size(), -1, true, "HarvestMath")

func _compute_yield(_idx: int) -> void:
    # Perform expensive per-item math here
    pass

# 4. Type-Safe resource Dictionaries
# EXPERT NOTE: Enforces strictly typed dictionaries to prevent bad data entries/crashes.
var warehouse: Dictionary[StringName, int] = {
    &"wood": 0,
    &"stone": 0
}

# 5. SceneTreeTimer for Harvesting Delays
# EXPERT NOTE: Creates an inline, one-shot timer without needing a physical Timer node.
func gather_resource(type: StringName, duration: float) -> void:
    await get_tree().create_timer(duration).timeout
    warehouse[type] += 1

# 6. Global Signal Bus for UI decoupling
# EXPERT NOTE: Broadcast changes via signals rather than direct node references.
signal resource_updated(type: StringName, total: int)

func update_stock(type: StringName, amount: int) -> void:
    warehouse[type] += amount
    resource_updated.emit(type, warehouse[type])

# 7. Unbinding Signal Parameters
# EXPERT NOTE: Drops unused signal arguments natively for cleaner callbacks.
func setup_ui_connections(btn: Button) -> void:
    btn.pressed.connect(_on_harvest_start.unbind(1))

func _on_harvest_start() -> void:
    pass

# 8. Optimized Array Reductions for Income
# EXPERT NOTE: Uses optimized C++ internal loops to quickly sum all generator outputs.
func get_total_income(generators: Array[int]) -> int:
    return generators.reduce(func(sum, val): return sum + val, 0)

# 9. Format Strings for Resource Readouts
# EXPERT NOTE: Neatly formats string data for localized UIs.
func get_formatted_amount(type: StringName, amount: int) -> String:
    return tr("HARVEST_LABEL").format({ "type": type, "count": amount })

# 10. Thread-Safe Mutex Locking
# EXPERT NOTE: Ensures background threads don't corrupt the main inventory total.
var _inventory_mutex := Mutex.new()
var total_resources := 0

func add_resource_safely(amount: int) -> void:
    _inventory_mutex.lock()
    total_resources += amount
    _inventory_mutex.unlock()
