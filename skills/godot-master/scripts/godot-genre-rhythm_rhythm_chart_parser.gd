# skills/genre-rhythm/code/rhythm_chart_parser.gd
extends Node

## Rhythm Chart Parser Expert Pattern
## Parses JSON charts and maps notes to precise sub-frame timestamps.

class Note:
    var time: float # In seconds
    var lane: int
    var type: String

var _active_chart: Array[Note] = []

func load_chart(json_path: String) -> void:
    var file = FileAccess.open(json_path, FileAccess.READ)
    if not file: return
    
    var json = JSON.parse_string(file.get_as_text())
    if not json or not json.has("notes"): return
    
    _active_chart.clear()
    for n_data in json["notes"]:
        var note = Note.new()
        note.time = n_data["time"]
        note.lane = n_data["lane"]
        note.type = n_data.get("type", "standard")
        _active_chart.append(note)
        
    # 1. Sort by Time (Critical for processing)
    _active_chart.sort_custom(func(a, b): return a.time < b.time)
    print("Chart Loaded: ", _active_chart.size(), " notes.")

func get_notes_in_range(start_time: float, end_time: float) -> Array[Note]:
    # 2. Optimized Window Query
    var notes: Array[Note] = []
    for note in _active_chart:
        if note.time >= start_time and note.time <= end_time:
            notes.append(note)
        elif note.time > end_time:
            break # Optimized exit
    return notes

## EXPERT NOTE:
## For performance with large charts (1000+ notes), use a 
## BINARY SEARCH (Array.bsearch_custom) to find the start index 
## of the time window rather than a linear loop.
## For 'genre-rhythm', prioritize JSON over binary formats to allow 
## for easy community modding and chart editing.
