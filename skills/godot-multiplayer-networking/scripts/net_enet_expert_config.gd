class_name NetENetExpertConfig
extends Node

## Expert ENet Tuning.
## Configures internal ENet settings for competitive-grade networking.

func setup_enet_peer(is_server: bool, port: int, max_clients: int = 32) -> ENetMultiplayerPeer:
	var peer = ENetMultiplayerPeer.new()
	var err: Error
	
	if is_server:
		err = peer.create_server(port, max_clients)
	else:
		err = peer.create_client("127.0.0.1", port)
	
	if err != OK: return null
	
	# Expert Tuning
	var host: ENetHost = peer.get_host()
	host.compress(ENetHost.COMPRESS_RANGE_CODER) # Efficient for dynamic packet sizes
	host.set_max_channels(3) # [0: Reliable, 1: Unreliable, 2: Ordered]
	
	# Limits
	host.set_bandwidth_limit(1024 * 1024, 1024 * 1024) # 1MB up/down
	
	return peer

## Rule: Use tailored Channels (Reliable vs Unreliable) to avoid Head-of-Line blocking.
