class_name NetUPNPDiscoveryLogic
extends Node

## Expert UPNP & Local Discovery.
## Automates port forwarding and local peer discovery for P2P play.

func setup_upnp(port: int) -> void:
	var upnp = UPNP.new()
	var error = upnp.discover()
	
	if error == OK:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			upnp.add_port_mapping(port)
			print("UPNP: Port %d forwarded successfully." % port)
	else:
		printerr("UPNP: Discovery failed with error %d" % error)

## Tip: Local discovery can be handled via 'PacketPeerUDP' broadcasting on the local subnet.
