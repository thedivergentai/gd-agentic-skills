# skills/multiplayer-networking/code/client_prediction_synchronizer.gd
extends MultiplayerSynchronizer

## Client-Side Prediction Expert Pattern
## Manages immediate client movement with server-authoritative correction.

@export var player: CharacterBody3D

# Simple history to store local movements for reconciliation
var _history: Array = [] # { "id": int, "pos": Vector3, "delta": float }
var _input_id: int = 0

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        # SERVER: Process and Send Verified State
        _server_validate_movement()
    else:
        # CLIENT: Predict and Record
        _predict_local_movement(delta)

func _predict_local_movement(delta: float) -> void:
    var input_dir = Input.get_vector("left", "right", "up", "down")
    _input_id += 1
    
    # 1. Immediate Client-Side Response
    player.velocity = Vector3(input_dir.x, 0, input_dir.y) * 5.0
    player.move_and_slide()
    
    # 2. Record for Reconciliation
    _history.append({
        "id": _input_id,
        "pos": player.global_position,
        "delta": delta
    })

func _server_validate_movement() -> void:
    # 3. Authoritative Correction
    # If client pos deviates too much from server result, snap back.
    # Note: Expert implementation would re-simulate from last valid 'id'.
    pass

## EXPERT NOTE:
## Use 'Snapshot Interpolation' for other players. Instead of snapping to 
## the newest position, keep a buffer [100ms] and interpolate between 
## the last two received states to ensure silky smooth movement even 
## with jitter.
## NEVER trust client-provided health or physics values. The Server MUST 
## handle all damage calculations and broadcast results via 
## 'MultiplayerSynchronizer'.
