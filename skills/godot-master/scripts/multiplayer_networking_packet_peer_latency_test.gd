# packet_peer_latency_test.gd
# Measuring ping and network jitter
extends Node

var last_ping_time: int = 0

func _process(_delta):
	if Time.get_ticks_msec() - last_ping_time > 1000:
		check_ping.rpc()
		last_ping_time = Time.get_ticks_msec()

@rpc("any_peer", "call_remote", "unreliable")
func check_ping():
	if multiplayer.is_server():
		return_ping.rpc_id(multiplayer.get_remote_sender_id(), Time.get_ticks_msec())

@rpc("authority", "call_remote", "unreliable")
func return_ping(server_time: int):
	var latency = Time.get_ticks_msec() - server_time
	print("Latency: ", latency, "ms")
