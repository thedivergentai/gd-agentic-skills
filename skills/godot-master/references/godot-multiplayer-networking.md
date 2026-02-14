> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Multiplayer Networking**. Accessed via Godot Master.

# Multiplayer Networking

Expert blueprint for high-level networking, covering ENet peers, RPC architecture, authoritative server models, and state synchronization.

## Available Scripts

### [server_authoritative_controller.gd](../scripts/godot-multiplayer-networking_server_authoritative_controller.gd)
Advanced player controller for authoritative server architectures. Implements client-side prediction, server reconciliation, and state interpolation to provide a lag-free experience.

### [client_prediction_synchronizer.gd](../scripts/godot-multiplayer-networking_client_prediction_synchronizer.gd)
Specialized synchronizer logic that allows a local client to predict its own movement while ensuring the server remains the ultimate authority on all physics interactions.


## NEVER Do

- **NEVER trust client-provided data for gameplay logic** — If a client sends an RPC saying `"deal_damage(9999)"`, a hacker can easily exploit this. The server MUST validate all requests: `if not multiplayer.is_server(): return`.
- **NEVER use `@rpc("any_peer")` for critical actions** — This allows any client to trigger the function on any other client. Use `@rpc("authority")` for everything except input and chat messages.
- **NEVER use `"reliable"` RPCs for high-frequency data** — Syncing positions at 60Hz with reliable delivery will saturate bandwidth and cause massive lag. Use `"unreliable"` for any data where the latest state is more important than missing a frame.
- **NEVER process local input on remote puppets** — Always check `is_multiplayer_authority()` before handling keyboard/mouse input to ensure you aren't accidentally controlling other players' characters on your screen.
- **NEVER sync unnecessary properties** — Avoid syncing visual-only properties like animation frames or local color choices via `MultiplayerSynchronizer`. Only sync data required for gameplay logic to save bandwidth.
- **NEVER teleport remote players directly to their new coordinates** — Snapping `position = new_pos` causes jitter. Always use `lerp()` or `slerp()` to smoothly interpolate remote units between their last known positions.

---

## Networking Models
1. **Authoritative Server**: The server runs the "real" game; clients send inputs and render the results provided by the server. Essential for competitive games.
2. **Peer-to-Peer (P2P)**: Players connect directly to each other. One player usually acts as the host. Ideal for small co-op games.

## RPC Modes
- `@rpc("authority")`: Only the master peer can call this.
- `@rpc("any_peer")`: Any client can call this (use with caution).
- `"call_local"`: The function also runs on the machine that called it.
- `"call_remote"`: The function only runs on the other machines.

## Spawning & Synchronization
- **MultiplayerSpawner**: Automatically synchronizes the instantiation and deletion of nodes across the network.
- **MultiplayerSynchronizer**: Transparently syncs property values (position, scale, stats) between the authority and puppets.

## Client-Side Prediction
To eliminate perceived lag:
1. Client processes input and moves immediately.
2. Client sends input to Server.
3. Server calculates the "canonical" position and sends it back.
4. If the Server position differs significantly from the Client's prediction, the Client "snaps" or smoothly reconciles to the server's version.

## Lobby Management
Use an AutoLoad (singleton) to track connected peers. Store player metadata (names, teams, ready status) in a `players` dictionary on the server and sync it to all clients upon change.

## Reference
- [Godot Docs: High-level Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
- [Godot Docs: RPCs and Synchronization](https://docs.godotengine.org/en/stable/tutorials/networking/index.html)
