# thread_safe_logger.gd
# Writing custom log files without blocking the main thread
class_name ThreadSafeLogger extends Logger

var _mutex := Mutex.new()
var _log_file: FileAccess

# EXPERT NOTE: Subclassing Logger and using a Mutex ensures 
# that logs from worker threads don't corrupt the file stream.

func _log_message(message: String, _error: bool):
	_mutex.lock()
	# Real implementations would write to _log_file here
	_mutex.unlock()
