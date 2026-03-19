# enet_br_server.gd
# Low-latency UDP server setup for high-player-count games
extends Node

# EXPERT NOTE: ENet is mandatory for Battle Royale games 
# to avoid TCP's head-of-line blocking and latency spikes.

func start_match_server(port: int = 7000):
	var peer := ENetMultiplayerPeer.new()
	# Unlimited bandwidth, 0 channels (max performance)
	var err = peer.create_server(port, 100) # 100 players
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Match server spawned on port ", port)
