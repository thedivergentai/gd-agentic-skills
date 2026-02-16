# godot-master/scripts/fighting_fighting_input_buffer.gd
extends Node

## Fighting Input Buffer
## Deterministic input buffering and history for fighting games.
## Stores inputs frame-by-frame to allow complex motion inputs (Hadoken, etc).

class_name FightingInputBuffer

# Config
const BUFFER_SIZE: int = 60 # 1 second at 60fps
const LENIENCY_FRAMES: int = 5 # Buffer window

# Frame Data
var input_history: Array[Dictionary] = [] # Array of {frame: int, inputs: int (bitmask)}
var current_frame: int = 0
var game_running: bool = false

# Input Flags (Bitmask)
enum Buttons {
    UP = 1,
    DOWN = 2,
    LEFT = 4,
    RIGHT = 8,
    LIGHT_PUNCH = 16,
    HEAVY_PUNCH = 32,
    LIGHT_KICK = 64,
    HEAVY_KICK = 128
}

func _ready() -> void:
    # Use physics process for fixed timestep (critical for fighting games)
    set_physics_process(true)

func _physics_process(_delta: float) -> void:
    current_frame += 1
    
    var current_inputs = _read_hardware_inputs()
    
    # Store history
    input_history.push_back({
        "frame": current_frame,
        "inputs": current_inputs
    })
    
    if input_history.size() > BUFFER_SIZE:
        input_history.pop_front()
        
    _check_special_moves(current_frame)

func _read_hardware_inputs() -> int:
    var mask = 0
    if Input.is_action_pressed("fight_up"): mask |= Buttons.UP
    if Input.is_action_pressed("fight_down"): mask |= Buttons.DOWN
    if Input.is_action_pressed("fight_left"): mask |= Buttons.LEFT
    if Input.is_action_pressed("fight_right"): mask |= Buttons.RIGHT
    if Input.is_action_just_pressed("fight_lp"): mask |= Buttons.LIGHT_PUNCH
    # ... etc
    return mask

func _check_special_moves(frame_now: int) -> void:
    # Example: Quarter Circle Forward (Down -> Down+Forward -> Forward + Punch)
    # Simplified check logic
    
    if is_button_just_pressed(Buttons.LIGHT_PUNCH, frame_now):
        # Look back for motion
        if check_motion_sequence([Buttons.DOWN, Buttons.DOWN | Buttons.RIGHT, Buttons.RIGHT], frame_now, 15):
             print("HADOKEN!")

func is_button_just_pressed(btn_mask: int, frame: int) -> bool:
    # Check if pressed this frame but NOT last frame
    var curr = get_input_at(frame)
    var prev = get_input_at(frame - 1)
    return (curr & btn_mask) and not (prev & btn_mask)

func get_input_at(frame: int) -> int:
    # Iterate history backwards
    for i in range(input_history.size() - 1, -1, -1):
        if input_history[i].frame == frame:
            return input_history[i].inputs
    return 0

func check_motion_sequence(sequence: Array, end_frame: int, window: int) -> bool:
    var seq_idx = sequence.size() - 1
    var current_search_frame = end_frame
    
    # Trace back
    while current_search_frame > end_frame - window and seq_idx >= 0:
        var inputs = get_input_at(current_search_frame)
        var target = sequence[seq_idx]
        
        # Fuzzy match: does functionality hold? 
        # (Simply checking if the bitmask contains the target bits)
        if (inputs & target) == target:
            seq_idx -= 1
        
        current_search_frame -= 1
        
    return seq_idx < 0

## EXPERT USAGE:
## Autoload this node. Bind your fighter's state machine to check `FightingInputBuffer.is_button_just_pressed(...)`.
