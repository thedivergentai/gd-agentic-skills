# websocket_server_compat.gd
# WebSocket implementation for HTML5/Web browser servers
extends Node

# EXPERT NOTE: ENet is UDP-only and unsupported in browsers. 
# WebSocketMultiplayerPeer is required for web compatibility.

func start_web_server(port: int):
	var peer := WebSocketMultiplayerPeer.new()
	var err = peer.create_server(port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("WebSocket Server active on port ", port)
