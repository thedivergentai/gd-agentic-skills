# dynamic_bpm_handler.gd
extends Node
class_name DynamicBPMHandler

# Handling Mid-Song Tempo Changes
# Adjusts beat calculation based on tempo map markers.

struct BPMMarker:
    var beat: float
    var time: float
    var bpm: float

var bpm_markers: Array[BPMMarker] = []

func get_beat_at_time(song_time: float) -> float:
    # Pattern: Find the most recent BPM marker and calculate beat offset.
    var current_marker = bpm_markers[0]
    for marker in bpm_markers:
        if marker.time <= song_time:
            current_marker = marker
        else:
            break
            
    var elapsed = song_time - current_marker.time
    return current_marker.beat + (elapsed * (current_marker.bpm / 60.0))
