class_name NetLANDiscovery
extends Node

## Expert LAN Discovery (UDP Broadcast).
## Allows peers to find local servers without external master servers.

const BROADCAST_PORT = 12345
var udp := PacketPeerUDP.new()

func _ready() -> void:
	udp.bind(BROADCAST_PORT)

func broadcast_presence(server_name: String) -> void:
	udp.set_dest_address("255.255.255.255", BROADCAST_PORT)
	udp.put_packet(server_name.to_utf8_buffer())

func _process(_delta) -> void:
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var msg = packet.get_string_from_utf8()
		# Add to local server list...

## Rule: UDP broadcasting is for LAN only. For Internet discovery, use an external Web API bridge.
