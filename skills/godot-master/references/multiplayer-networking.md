---
name: godot-multiplayer-networking
description: "Expert blueprint for multiplayer networking (Among Us, Brawlhalla, Terraria) using Godot's high-level API covering RPCs, state synchronization, authoritative servers, client prediction, and lobby systems. Use when building online multiplayer, LAN co-op, or networked games. Keywords multiplayer, RPC, ENetMultiplayerPeer, MultiplayerSynchronizer, authority, client prediction, rollback."
---

# Multiplayer Networking

Authoritative servers, client prediction, and state synchronization define robust multiplayer.

### [net_enet_expert_config.gd](../scripts/multiplayer_networking_net_enet_expert_config.gd)
Expert logic for tuning ENet channels, compression, and bandwidth thresholds.

### [net_packet_bit_packer.gd](../scripts/multiplayer_networking_net_packet_bit_packer.gd)
Professional manual serialization tools for bit-packing data into PackedByteArray.

### [net_headless_server_auto_start.gd](../scripts/multiplayer_networking_net_headless_server_auto_start.gd)
Logic for detecting dedicated server mode and parsing CLI arguments for headless launch.

### [net_heartbeat_monitor.gd](../scripts/multiplayer_networking_net_heartbeat_monitor.gd)
RTT (Round Trip Time) and Jitter monitoring system for high-fidelity lag tracking.

### [net_lan_discovery.gd](../scripts/multiplayer_networking_net_lan_discovery.gd)
UDP broadcasting system for local server discovery without master servers.

### [net_adaptive_sync_throttle.gd](../scripts/multiplayer_networking_net_adaptive_sync_throttle.gd)
Dynamic synchronization manager that adapts sync-rates to peer connection quality.

### [net_anti_desync_reconciler.gd](../scripts/multiplayer_networking_net_anti_desync_reconciler.gd)
Server-authoritative state validation and forced-correction logic.

### [net_visibility_grid_culling.gd](../scripts/multiplayer_networking_net_visibility_grid_culling.gd)
Interest Management system for optimizing bandwidth in large-scale worlds.

### [net_packet_rate_limiter.gd](../scripts/multiplayer_networking_net_packet_rate_limiter.gd)
Essential flood-protection and anti-spam manager for RPC security.

### [net_custom_id_mapper.gd](../scripts/multiplayer_networking_net_custom_id_mapper.gd)
Mapping utility for linking permanent UserIDs to volatile Network PeerIDs.

## NEVER Do (Expert Networking Rules)

### Core Architecture
- **NEVER use `Reliable` for high-frequency data (Position/Movement)** — Reliable packets block all following packets until acknowledged (Head-of-Line blocking). Use `UnreliableOrdered`.
- **NEVER trust the client for shared state (Health/Money/Inventory)** — Clients should only suggest actions. The Server MUST validate and broadcast the result.
- **NEVER hardcode the Server IP** — Always allow for discovery (`net_lan_discovery.gd`) or pass the IP via CLI/UI.

### Performance & Bandwidth
- **NEVER send the same data every frame** — Use `net_adaptive_sync_throttle.gd` to only send updates when state changes significantly or at fixed Hz intervals (e.g., 20Hz).
- **NEVER use `JSON` for high-speed synchronization** — String serialization is massive over the wire. Use bit-packing (`net_packet_bit_packer.gd`) to keep packets under 100 bytes.
- **NEVER broadcast to all peers if it's not needed** — In large worlds, use Interest Management (`net_visibility_grid_culling.gd`). A player in the forest doesn't need the position of a player in the city.

### Security
- **NEVER allow unlimited RPC calls per second** — An attacker can flood the server with 1,000 "Attack" RPCs to crash the game. Use `net_packet_rate_limiter.gd`.
- **NEVER expose PeerIDs to the end-user** — PeerIDs are internal. Always map them to persistent `UserIDs` (`net_custom_id_mapper.gd`) from a database.
- **NEVER run a dedicated server with a GUI enabled** — Use `--headless` (`net_headless_server_auto_start.gd`) to save resources and ensure stability.

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
- Master Skill: [godot-master](../SKILL.md)
