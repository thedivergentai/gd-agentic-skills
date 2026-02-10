---
name: godot-multiplayer-networking
description: "Expert blueprint for multiplayer networking (Among Us, Brawlhalla, Terraria) using Godot's high-level API covering RPCs, state synchronization, authoritative servers, client prediction, and lobby systems. Use when building online multiplayer, LAN co-op, or networked games. Keywords multiplayer, RPC, ENetMultiplayerPeer, MultiplayerSynchronizer, authority, client prediction, rollback."
---

# Multiplayer Networking

Authoritative servers, client prediction, and state synchronization define robust multiplayer.

## Available Scripts

### [server_authoritative_controller.gd](scripts/server_authoritative_controller.gd)
Advanced player controller with client prediction, server reconciliation, and interpolation.

### [client_prediction_synchronizer.gd](scripts/client_prediction_synchronizer.gd)
Expert client-side prediction with server reconciliation pattern.

## NEVER Do in Multiplayer Networking

- **NEVER trust client input without server validation** — Client sends "deal 9999 damage" RPC? Cheating. Server MUST validate actions: `if not multiplayer.is_server(): return`.
- **NEVER use `@rpc("any_peer")` for gameplay actions** — Any peer can call = cheating vector. Use `@rpc("authority")` for damage/spawns. Only `any_peer` for chat/cosmetics.
- **NEVER use reliable RPCs for position updates** — 60 position updates/sec with `"reliable"` = bandwidth explosion + lag. Use `"unreliable"` for frequent, non-critical data.
- **NEVER forget to set multiplayer authority** — Both client and server process input? Desync. Call `set_multiplayer_authority(peer_id)` and check `is_multiplayer_authority()`.
- **NEVER sync every variable** — MultiplayerSynchronizer syncing 50 properties = bandwidth waste. Only sync state OTHER clients need (skip animation frame, local UI state).
- **NEVER block on `peer.create_server()`** — ENet is async. Calling `multiplayer.multiplayer_peer = peer` before server ready = crash. Await `peer_connected` signal.
- **NEVER forget interpolation for remote players** — Teleporting remote players (direct position assignment) = jittery. Use `lerp()` to smooth between received positions.

---

**Authoritative Server Model:**
- Server validates all game state
- Clients send inputs, receive state
- Prevents cheating

**Peer-to-Peer:**
- Direct player connections
- Good for small player counts
- No dedicated server needed

## Basic Setup

### Create Multiplayer Peer

```gdscript
extends Node

var peer := ENetMultiplayerPeer.new()

func host_game(port: int = 7777) -> void:
    peer.create_server(port, 4)  # Max 4 players
    multiplayer.multiplayer_peer = peer
    print("Server started on port ", port)

func join_game(ip: String, port: int = 7777) -> void:
    peer.create_client(ip, port)
    multiplayer.multiplayer_peer = peer
    print("Connecting to ", ip)
```

### Connection Signals

```gdscript
func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)

func _on_peer_connected(id: int) -> void:
    print("Player connected: ", id)

func _on_peer_disconnected(id: int) -> void:
    print("Player disconnected: ", id)

func _on_connected() -> void:
    print("Connected to server!")

func _on_connection_failed() -> void:
    print("Connection failed")
```

## Remote Procedure Calls (RPCs)

### Basic RPC

```gdscript
extends CharacterBody2D

# Called on all peers
@rpc("any_peer", "call_local")
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

# Usage: Call on specific peer
take_damage.rpc_id(1, 50)  # Call on server (ID 1)
take_damage.rpc(50)  # Call on all peers
```

### RPC Modes

```gdscript
# Only server can call, runs on all clients
@rpc("authority", "call_remote")
func server_spawn_enemy(pos: Vector2) -> void:
    pass

# Any peer can call, runs locally too
@rpc("any_peer", "call_local")
func player_chat(message: String) -> void:
    pass

# Reliable (TCP-like) vs Unreliable (UDP-like)
@rpc("any_peer", "call_local", "reliable")
func important_event() -> void:
    pass

@rpc("any_peer", "call_local", "unreliable")
func position_update(pos: Vector2) -> void:
    pass
```

## MultiplayerSpawner

```gdscript
# Add MultiplayerSpawner node
# Set spawn path and scenes

extends Node

@onready var spawner := $MultiplayerSpawner

func _ready() -> void:
    spawner.spawn_function = spawn_player

func spawn_player(data: Variant) -> Node:
    var player := preload("res://player.tscn").instantiate()
    player.name = str(data)  # Use peer ID as name
    return player
```

## MultiplayerSynchronizer

```gdscript
# Add to synchronized node
# Set properties to sync

# Scene structure:
# Player (CharacterBody2D)
#   ├─ MultiplayerSynchronizer
#   │    └─ Replication config:
#   │         - position (sync)
#   │         - velocity (sync)
#   │         - health (sync)
#   └─ Sprite2D
```

## Lobby System

```gdscript
# lobby_manager.gd (AutoLoad)
extends Node

signal player_joined(id: int, info: Dictionary)
signal player_left(id: int)

var players: Dictionary = {}

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
    # Request player info
    request_player_info.rpc_id(id)

func _on_peer_disconnected(id: int) -> void:
    players.erase(id)
    player_left.emit(id)

@rpc("any_peer", "reliable")
func request_player_info() -> void:
    var sender_id := multiplayer.get_remote_sender_id()
    receive_player_info.rpc_id(sender_id, {
        "name": PlayerSettings.player_name,
        "color": PlayerSettings.player_color
    })

@rpc("any_peer", "reliable")
func receive_player_info(info: Dictionary) -> void:
    var sender_id := multiplayer.get_remote_sender_id()
    players[sender_id] = info
    player_joined.emit(sender_id, info)
```

## State Synchronization

```gdscript
extends CharacterBody2D

var puppet_position: Vector2
var puppet_velocity: Vector2

func _physics_process(delta: float) -> void:
    if is_multiplayer_authority():
        # Local player: process input
        _handle_input(delta)
        move_and_slide()
        
        # Send position to others
        sync_position.rpc(global_position, velocity)
    else:
        # Remote player: interpolate
        global_position = global_position.lerp(puppet_position, 10.0 * delta)

@rpc("any_peer", "unreliable")
func sync_position(pos: Vector2, vel: Vector2) -> void:
    puppet_position = pos
    puppet_velocity = vel
```

## Authority

```gdscript
# Check who owns this node
func _ready() -> void:
    # Set authority to owner peer
    set_multiplayer_authority(peer_id)

func _process(delta: float) -> void:
    if not is_multiplayer_authority():
        return  # Skip if not owner
    
    # Only authority processes this
```

## Best Practices

### 1. Validate on Server

```gdscript
@rpc("any_peer", "call_local")
func player_action(action: String) -> void:
    if not multiplayer.is_server():
        return  # Only server validates
    
    var sender := multiplayer.get_remote_sender_id()
    if not _is_valid_action(sender, action):
        return
    
    _apply_action.rpc(sender, action)
```

### 2. Use Unreliable for Frequent Updates

```gdscript
# Position: unreliable (frequent)
@rpc("any_peer", "unreliable")
func sync_position(pos: Vector2) -> void:
    pass

# Damage: reliable (important)
@rpc("authority", "reliable")
func apply_damage(amount: int) -> void:
    pass
```

### 3. Interpolation for Smooth Movement

```gdscript
var target_position: Vector2

func _process(delta: float) -> void:
    if not is_multiplayer_authority():
        position = position.lerp(target_position, 15.0 * delta)
```

## Reference
- [Godot Docs: High-level Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
