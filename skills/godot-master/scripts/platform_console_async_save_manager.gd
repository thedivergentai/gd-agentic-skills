class_name AsyncSaveManager
extends Node

## Expert Threaded Save System for Console certification.
## Prevents main-thread stutters and implements atomic file writing.

var _save_mutex := Mutex.new()
var _is_saving := false

func execute_save(data: Dictionary, slot: int = 1) -> void:
	_save_mutex.lock()
	if _is_saving:
		_save_mutex.unlock()
		return
	_is_saving = true
	_save_mutex.unlock()
	
	# Offload I/O to background thread pooled workers
	WorkerThreadPool.add_task(_write_to_disk.bind(data, slot))

func _write_to_disk(data: Dictionary, slot: int) -> void:
	var json_str = JSON.stringify(data)
	var final_path = "user://save_slot_%d.dat" % slot
	var temp_path = final_path + ".tmp"
	
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		
		# Atomic rename to protect against power-loss corruption
		DirAccess.rename_absolute(temp_path, final_path)
	
	_save_mutex.lock()
	_is_saving = false
	_save_mutex.unlock()
