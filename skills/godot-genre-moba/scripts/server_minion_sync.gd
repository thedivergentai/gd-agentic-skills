# server_minion_sync.gd
extends Node
class_name ServerMinionSync

# Centralized Server-Authoritative Minion Sync
# Batches hundreds of minion positions into a single byte array for low-overhead sync.

func _physics_process(_delta: float) -> void:
    # Only the server should broadcast state.
    if multiplayer.is_server():
        var minion_data := PackedFloat32Array()
        var minions := get_tree().get_nodes_in_group(&"minions")
        
        for minion in minions:
            # Sync core transform data to minimal primitives.
            minion_data.push_back(minion.global_position.x)
            minion_data.push_back(minion.global_position.y)
        
        # Bypasses high-overhead RPCs, sending raw bytes unreliably for maximum speed.
        multiplayer.send_bytes(minion_data.to_byte_array(), 0, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
