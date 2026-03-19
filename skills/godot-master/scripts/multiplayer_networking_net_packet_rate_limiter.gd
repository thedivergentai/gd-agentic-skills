class_name NetPacketRateLimiter
extends Node

## Expert Packet Rate Limiter.
## Protects server against malicious clients flooding RPCs.

@export var max_packets_per_sec: int = 60
var peer_buckets: Dictionary = {} # PeerID: Count

func check_rate(peer_id: int) -> bool:
	peer_buckets[peer_id] = peer_buckets.get(peer_id, 0) + 1
	if peer_buckets[peer_id] > max_packets_per_sec:
		print("Peer %d Kicked for Flooding" % peer_id)
		multiplayer.multiplayer_peer.disconnect_peer(peer_id)
		return false
	return true

func _on_timer_reset() -> void:
	peer_buckets.clear()

## Rule: Always rate-limit unauthenticated pings and movement packets to prevent DDoS-lite.
