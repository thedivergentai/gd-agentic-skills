# offline_progress_calculator.gd
extends Node

# Calculating Offline Ticks
# Measures real-world time passed while the application was closed.
func calculate_offline_progress(last_save_unix_time: float) -> float:
    # get_unix_time_from_system() returns persistent time since the Epoch.
    # NEVER use get_ticks_msec() for offline progress as it resets on boot.
    var current_time := Time.get_unix_time_from_system()
    var delta_seconds := current_time - last_save_unix_time
    
    # Returns raw seconds; usually passed to a simulation loop.
    return delta_seconds
