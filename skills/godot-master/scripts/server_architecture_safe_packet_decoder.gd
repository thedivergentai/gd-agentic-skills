# safe_packet_decoder.gd
# Preventing RCE vulnerabilities in network serialization
extends Node

# EXPERT NOTE: NEVER pass true to get_var/set_var on untrusted data. 
# Object decoding allows a client to trigger arbitrary code.

func process_untrusted_packet(packet_peer: PacketPeerUDP):
	if packet_peer.get_available_packet_count() > 0:
		# EXPERT: Passing 'false' forbids Object decoding, preventing RCE.
		var data: Variant = packet_peer.get_var(false)
		_handle_data(data)

func _handle_data(data: Variant): pass
