class_name NetHeartbeatMonitor
extends Node

## Expert Heartbeat & Latency Monitor.
## Measures RTT (Round Trip Time) manually for precise lag display.

var rtt_msec: int = 0
var last_ping_time: int = 0

func _on_timer_timeout() -> void:
	last_ping_time = Time.get_ticks_msec()
	# Call unreliably to avoid blocking
	ping_server.rpc_id(1, last_ping_time)

@rpc("any_peer", "unreliable")
func ping_server(t: int) -> void:
	pong_client.rpc_id(multiplayer.get_remote_sender_id(), t)

@rpc("authority", "unreliable")
func pong_client(t: int) -> void:
	rtt_msec = Time.get_ticks_msec() - t

## Tip: Display Jitter (variation in RTT) alongside Ping to help players diagnose bad connections.
