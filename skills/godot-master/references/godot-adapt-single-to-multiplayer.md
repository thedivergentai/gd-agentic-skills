> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Adapt: Single to Multiplayer**. Accessed via Godot Master.

# Adapt: Single to Multiplayer

Expert blueprint for retrofitting networking into single-player foundations, emphasizing authoritative server models and lag compensation.

## Available Scripts

### [multiplayer_sync.gd](../scripts/godot-adapt-single-to-multiplayer_multiplayer_sync.gd)
Demonstrates latency-aware synchronization using `MultiplayerSynchronizer`. Includes logic for peer interpolation (lerping to network positions) and authority-based property updates.

### [rpc_bridge.gd](../scripts/godot-adapt-single-to-multiplayer_rpc_bridge.gd)
Implementation of the Signal-to-RPC bridge pattern. Shows the authority guard pattern: Client Request → Server Validation → Server Broadcast. Crucial for anti-cheat and state consistency.


## NEVER Do

- **NEVER trust client-sent data for game state** — A client saying "I have 100 gold" is a security risk. The server must be the source of truth; clients should only send inputs or requests.
- **NEVER use group-based authority checks** — `get_nodes_in_group("player")` is unreliable for networking. Use `is_multiplayer_authority()` and check specifically for the peer ID.
- **NEVER forget to set `multiplayer_authority` on spawner instances** — If the authority isn't assigned to the correct peer ID during instantiation, movement and inputs will desync immediately.
- **NEVER run full physics simulations on both client and server simultaneously** — This causes "double movement" or jitters. Use **Client Prediction** while the server performs the authoritative check.
- **NEVER send raw raw data every single frame** — Bandwidth is precious. Pack inputs into batches or use the `"unreliable"` RPC mode for high-frequency data like player rotation.
- **NEVER ignore the round-trip time (RTT/Ping)** — High ping makes games feel sluggish. Always implement basic **interpolation** for other players so they don't appear to "pop" across the screen.

---

## The Migration Pipeline
1. **Decouple Input**: Move movement logic out of `_process` and into a method that takes a `Vector2` input. Call this method locally (predicted) and on the server (authoritative).
2. **Assign Authority**: Use `set_multiplayer_authority(peer_id)` so the engine knows which client controls which player character.
3. **Synchronize Properties**: Use `MultiplayerSynchronizer` for smooth, low-frequency state updates like Health, Mana, and inventory counts.
4. **RPC Communication**: Use `@rpc("authority", "reliable")` for critical events like deaths, damage, and level changes.

## Client-Side Prediction (CSP)
To eliminate "input lag":
1. Client applies movement locally *before* the server confirms it.
2. Client stores its predicted positions and inputs in a buffer.
3. Server eventually sends back the "true" position.
4. If the difference is too large, the client clears its buffer and matches the server's state (Reconciliation).

## Anti-Cheat: Validation Guard
Always validate the *possibility* of an action. 
Example: If a client requests to teleport to `Vector2(999, 999)`, the server should check: `if current_pos.distance_to(new_pos) > max_speed * delta: reject_request()`.

## Multi-Instance Testing
To test networking locally on a single machine:
1. Export a "Project" and run multiple instances.
2. Or use the Godot Editor's "Network" settings to launch 2+ instances automatically when pressing Play.

## Reference
- [Godot Docs: Introduction to Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
- [Godot Docs: Synchronizing Gameplay](https://docs.godotengine.org/en/stable/tutorials/networking/multiplayer_synchronizer.html)
