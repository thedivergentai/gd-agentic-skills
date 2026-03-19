# custom_monitor_profiler.gd
# Monitoring performance bottlenecks in real-time
extends Label

# EXPERT NOTE: Use Performance.get_monitor to create 
# custom debug overlays that catch regression during play.

func _process(_delta):
	text = "FPS: %d\n" % Engine.get_frames_per_second()
	text += "Draw Calls: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	text += "Static Memory: %s\n" % String.humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC))
	text += "Objects: %d\n" % Performance.get_monitor(Performance.OBJECT_COUNT)
