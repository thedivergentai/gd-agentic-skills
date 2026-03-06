# ghost_replayer.gd
# [GDSKILLS] godot-game-loop-time-trial
# EXPORT_REFERENCE: ghost_replayer.gd

extends Node3D

@export var ghost_visual: Node3D
@export var interpolation_enabled: bool = true

var recording_data: Array = []
var is_playing: bool = false
var playback_time: float = 0.0
var _data_size: int = 0

func start_playback(data: Array) -> void:
	if data.is_empty():
		return
		
	recording_data = data
	_data_size = recording_data.size()
	playback_time = 0.0
	is_playing = true
	
	# Initial placement
	_apply_transform(recording_data[0])
	
	# Ensure visual is ready
	if ghost_visual:
		ghost_visual.show()

func stop_playback() -> void:
	is_playing = false
	if ghost_visual:
		ghost_visual.hide()

func _process(delta: float) -> void:
	if not is_playing:
		return
		
	playback_time += delta
	
	# Check for end of recording
	if playback_time >= recording_data[_data_size - 1].t:
		_apply_transform(recording_data[_data_size - 1])
		is_playing = false
		return
		
	_update_transform()

func _update_transform() -> void:
	# Find the current frame (Binary search could be grander, but linear is fine for <10 min runs)
	# Optimization: We assume sequential access, so we can track the last index.
	# For robustness, we'll just scan or use a simple look-ahead since samples are ordered.
	
	var idx = _find_keyframe_index(playback_time)
	if idx == -1: return

	var frame_a = recording_data[idx]
	var frame_b = recording_data[idx + 1]
	
	if not interpolation_enabled:
		_apply_transform(frame_a)
		return
		
	# Calculate t (0.0 to 1.0) between frames
	var duration = frame_b.t - frame_a.t
	if duration <= 0.0001:
		_apply_transform(frame_a)
		return
		
	var weight = (playback_time - frame_a.t) / duration
	
	var target_pos = frame_a.p.lerp(frame_b.p, weight)
	
	# Slerp for rotation requires Basis or Quat. Assuming 'r' is Vector3 (Euler) or Basis.
	# ghost_recorder saves global_rotation (Vector3 Euler) usually, but Quat is safer.
	# Let's assume recorder saves Vector3 for simplicity, but converting to Basis for slerp is better.
	var rot_a = Quaternion.from_euler(frame_a.r)
	var rot_b = Quaternion.from_euler(frame_b.r)
	var target_rot = rot_a.slerp(rot_b, weight).get_euler()
	
	if ghost_visual:
		ghost_visual.global_position = target_pos
		ghost_visual.global_rotation = target_rot

func _apply_transform(frame: Dictionary) -> void:
	if ghost_visual:
		ghost_visual.global_position = frame.p
		ghost_visual.global_rotation = frame.r

func _find_keyframe_index(time: float) -> int:
	# Returns index such that data[index].t <= time < data[index+1].t
	# Simple linear scan suitable for short replays. 
	# For long runs, store 'last_index' state to resume search.
	
	for i in range(0, _data_size - 1):
		if time < recording_data[i+1].t:
			return i
	return -1
