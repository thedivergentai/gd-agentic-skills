class_name NetDebugOverlayMonitor
extends CanvasLayer

## Expert Network Debug Monitor.
## Displays real-time RTT, Packet Loss, and Jitter.

@onready var label = $Label

func _process(_delta: float) -> void:
	var peer = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if not peer or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	
	# Note: ENet provides statistics per peer
	var stats = "Network Stats:\n"
	stats += "RTT: %dms\n" % peer.get_peer(1).get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	stats += "Loss: %d%%\n" % peer.get_peer(1).get_statistic(ENetPacketPeer.PEER_PACKET_LOSS)
	
	label.text = stats

## Rule: Always provide a network overlay during alpha/beta testing to catch ISP-routing issues.
