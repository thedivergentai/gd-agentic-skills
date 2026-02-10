---
name: godot-adapt-single-to-multiplayer
description: "Expert patterns for adding multiplayer to single-player games including client-server architecture, authoritative server design, MultiplayerSynchronizer, lag compensation (client prediction, server reconciliation), input buffering, and anti-cheat measures. Use when retrofitting multiplayer, porting to online play, or designing networked gameplay. Trigger keywords: MultiplayerPeer, ENetMultiplayerPeer, SceneMultiplayer, MultiplayerSynchronizer, rpc, rpc_id, multiplayer_authority, client_prediction, server_reconciliation, lag_compensation, rollback."
---

# Adapt: Single to Multiplayer

Expert guidance for retrofitting multiplayer into single-player games.

## NEVER Do

- **NEVER trust client input** — Always validate on server. Clients can send fake position/health/inventory data.
- **NEVER use get_tree().get_nodes_in_group() for authority checks** — Use `is_multiplayer_authority()` on individual nodes. Group iteration is unreliable for network identity.
- **NEVER forget to set multiplayer_authority** — Nodes without authority assignment will desync. Server should own world objects, clients own their player.
- **NEVER run physics on both client and server identically** — Leads to double-speed movement. Use client prediction with server reconciliation OR server-only physics.
- **NEVER send raw input every frame** — Buffer inputs client-side, send in batches (every 3-5 frames). Reduces bandwidth 60-80%.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [multiplayer_sync.gd](scripts/multiplayer_sync.gd)
Latency-aware synchronization with MultiplayerSynchronizer. Demonstrates peer interpolation (lerp to network position) and authority-based update logic.

### [rpc_bridge.gd](scripts/rpc_bridge.gd)
Signal-to-RPC bridge pattern. Shows authority guard pattern: client requests → server validates → server broadcasts. Essential for cheat prevention.

---

## Architecture Patterns

### Pattern 1: Authoritative Server (Recommended)

```gdscript
# Server validates ALL gameplay logic
# Clients send inputs → Server processes → Server broadcasts state

# Pros: Secure, prevents cheating
# Cons: Requires server hosting, lag affects gameplay

# Use for: Competitive games, PvP, games with economies
```

### Pattern 2: Peer-to-Peer (Lockstep)

```gdscript
# All clients run identical simulation
# Inputs synced, deterministic physics

# Pros: No dedicated server needed
# Cons: Vulnerable to cheating, desyncs common

# Use for: Co-op, casual games, small player counts (2-4)
```

### Pattern 3: Hybrid (Authority Transfer)

```gdscript
# Host acts as server
# Authority can transfer between peers

# Use for: 4-8 player co-op, party games
```

---

## Step-by-Step Migration

### Step 1: Separate Input from Logic

```gdscript
# ❌ BAD: Input directly modifies state (single-player)
extends CharacterBody2D

func _physics_process(delta: float) -> void:
    var input := Input.get_vector("left", "right", "up", "down")
    velocity = input.normalized() * SPEED
    move_and_slide()

# ✅ GOOD: Input → Logic separation

extends CharacterBody2D

var current_input := Vector2.ZERO

func _physics_process(delta: float) -> void:
    # Only read input if this is OUR player
    if is_multiplayer_authority():
        current_input = Input.get_vector("left", "right", "up", "down")
        # Send input to server (if we're client)
        if multiplayer.get_unique_id() != 1:  # Not server
            rpc_id(1, "receive_input", current_input)
    
    # EVERYONE processes movement (server + all clients)
    _process_movement(delta, current_input)

func _process_movement(delta: float, input: Vector2) -> void:
    velocity = input.normalized() * SPEED
    move_and_slide()

@rpc("any_peer", "call_remote", "unreliable")
func receive_input(input: Vector2) -> void:
    # Server receives client input
    current_input = input
```

### Step 2: Set Up Multiplayer Authority

```gdscript
# server_setup.gd
extends Node

const PORT = 7777
const MAX_PLAYERS = 4

func host_game() -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(PORT, MAX_PLAYERS)
    multiplayer.multiplayer_peer = peer
    
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    
    print("Server started on port %d" % PORT)

func join_game(ip: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_client(ip, PORT)
    multiplayer.multiplayer_peer = peer
    
    print("Connecting to %s:%d" % [ip, PORT])

func _on_player_connected(id: int) -> void:
    print("Player %d connected" % id)
    spawn_player(id)

func _on_player_disconnected(id: int) -> void:
    print("Player %d disconnected" % id)
    despawn_player(id)

func spawn_player(id: int) -> void:
    var player := preload("res://player.tscn").instantiate()
    player.name = str(id)  # CRITICAL: Name must be unique and match peer ID
    player.set_multiplayer_authority(id)  # Client owns their own player
    get_node("/root/World").add_child(player, true)  # true = replicate to all peers
```

### Step 3: Add MultiplayerSynchronizer

```gdscript
# Scene structure:
# Player (CharacterBody2D)
#   ├─ Sprite2D
#   ├─ CollisionShape2D
#   └─ MultiplayerSynchronizer

# MultiplayerSynchronizer setup (in editor):
# - Root Path: "../"  (points to Player node)
# - Replication Interval: 0.05  (20Hz updates)
# - Public Visibility: true
# - Synchronized Properties:
#     - position
#     - rotation
#     - velocity (optional, for interpolation)

# No code needed! MultiplayerSynchronizer auto-syncs properties
```

---

## Client Prediction & Server Reconciliation

### Problem: Lag Makes Game Feel Unresponsive

```gdscript
# Without prediction:
# 1. Client presses W
# 2. Input sent to server
# 3. Server processes (50ms later)
# 4. Server sends back position
# 5. Client sees movement (100ms RTT)
# Result: 100ms delay between input and visual feedback
```

### Solution: Client-Side Prediction

```gdscript
# player_controller.gd
extends CharacterBody2D

var input_buffer: Array = []
var server_state := {"position": Vector2.ZERO, "tick": 0}

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        var input := Input.get_vector("left", "right", "up", "down")
        
        # Client predicts movement IMMEDIATELY
        var tick := Engine.get_physics_frames()
        input_buffer.append({"input": input, "tick": tick})
        process_movement(input)
        
        # Send input to server
        if multiplayer.get_unique_id() != 1:
            rpc_id(1, "server_receive_input", input, tick)
    
    else:
        # Other players: just display synced position (no prediction)
        pass

@rpc("any_peer", "call_remote", "unreliable")
func server_receive_input(input: Vector2, client_tick: int) -> void:
    # Server processes input
    process_movement(input)
    
    # Send authoritative state back
    rpc_id(multiplayer.get_remote_sender_id(), "client_receive_state", position, client_tick)

@rpc("authority", "call_remote", "unreliable")
func client_receive_state(server_pos: Vector2, server_tick: int) -> void:
    # Reconciliation: check if prediction was correct
    var error := position.distance_to(server_pos)
    
    if error > 5.0:  # Threshold for correction
        # Snap to server position
        position = server_pos
        
        # Replay inputs that happened after server_tick
        for buffered_input in input_buffer:
            if buffered_input.tick > server_tick:
                process_movement(buffered_input.input)
    
    # Clean old inputs
    input_buffer = input_buffer.filter(func(i): return i.tick > server_tick)

func process_movement(input: Vector2) -> void:
    velocity = input.normalized() * SPEED
    move_and_slide()
```

---

## Lag Compensation Techniques

### Interpolation (Other Player Smoothing)

```gdscript
# Other players appear choppy due to packet loss/jitter
# Solution: Interpolate between received states

extends CharacterBody2D

var position_buffer: Array = []
const BUFFER_SIZE = 3  # Store last 3 positions

func _ready() -> void:
    if not is_multiplayer_authority():
        # Disable local physics, use interpolation
        set_physics_process(false)

func _process(delta: float) -> void:
    if not is_multiplayer_authority() and position_buffer.size() >= 2:
        # Interpolate between buffered positions
        var from := position_buffer[0]
        var to := position_buffer[1]
        var t := 0.2  # Interpolation speed
        
        position = position.lerp(to, t)
        
        if position.distance_to(to) < 1.0:
            position_buffer.pop_front()

# Called by MultiplayerSynchronizer when position updates
func _on_position_synced(new_pos: Vector2) -> void:
    position_buffer.append(new_pos)
    if position_buffer.size() > BUFFER_SIZE:
        position_buffer.pop_front()
```

---

## Anti-Cheat Measures

### Server-Side Validation

```gdscript
# server_validator.gd
extends Node

const MAX_SPEED = 300.0
const MAX_TELEPORT_DISTANCE = 50.0

@rpc("any_peer", "call_remote", "reliable")
func request_move(new_position: Vector2) -> void:
    var sender_id := multiplayer.get_remote_sender_id()
    var player := get_node("/root/World/" + str(sender_id))
    
    # Validate movement
    var distance := player.position.distance_to(new_position)
    var delta := get_physics_process_delta_time()
    var max_allowed := MAX_SPEED * delta
    
    if distance > max_allowed:
        push_warning("Player %d teleported %f units (max: %f)" % [sender_id, distance, max_allowed])
        # Reject movement, force server position
        rpc_id(sender_id, "force_position", player.position)
        return
    
    # Accept movement
    player.position = new_position

@rpc("authority", "call_remote", "reliable")
func force_position(server_position: Vector2) -> void:
    position = server_position
```

---

## Bandwidth Optimization

### Input Buffering

```gdscript
# ❌ BAD: Send input every frame (60 packets/s)
func _physics_process(delta: float) -> void:
    var input := get_input()
    rpc_id(1, "receive_input", input)

# ✅ GOOD: Send every 3rd frame (20 packets/s)
var input_timer := 0.0
const INPUT_SEND_RATE = 0.05  # 20 Hz

func _physics_process(delta: float) -> void:
    input_timer += delta
    if input_timer >= INPUT_SEND_RATE:
        var input := get_input()
        rpc_id(1, "receive_input", input)
        input_timer = 0.0
```

---

## Testing Multiplayer Locally

```gdscript
# Launch multiple instances for testing
# Run from command line:

# Windows:
# Server: Godot.exe --path . res://main.tscn -- --server
# Client 1: Godot.exe --path . res://main.tscn -- --client
# Client 2: Godot.exe --path . res://main.tscn -- --client

# Parse arguments in code:
func _ready() -> void:
    var args := OS.get_cmdline_args()
    if "--server" in args:
        host_game()
    elif "--client" in args:
        join_game("127.0.0.1")
```

---

## Decision Tree: Which Architecture?

| Factor | Authoritative Server | P2P Lockstep |
|--------|---------------------|--------------|
| Player count | 8-100+ | 2-4 |
| Cheat prevention | Critical | Not important |
| Server hosting | Available | Not available |
| Gameplay type | PvP, competitive | Co-op, casual |
| Lag tolerance | Medium (prediction helps) | Low (desyncs) |
| Development complexity | High | Medium |


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
