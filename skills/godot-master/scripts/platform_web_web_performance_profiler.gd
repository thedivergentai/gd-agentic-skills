class_name WebPerformanceProfiler
extends Node

## Expert performance profiler for WebGL/WebGPU.
## Logs memory and draw calls to the browser console.

func log_profle_data() -> void:
	if not OS.has_feature("web"): return
	
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var memory := OS.get_static_memory_usage() / 1024 / 1024
	
	JavaScriptBridge.eval("console.log('Godot Performance | Draw Calls: %d | Memory: %dMB');" % [draw_calls, memory])

## Tip: Keep draw calls under 500 for stable 60FPS on mid-range mobile browsers.
