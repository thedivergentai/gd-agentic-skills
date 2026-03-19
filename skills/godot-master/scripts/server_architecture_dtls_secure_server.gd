# dtls_secure_server.gd
# Encrypting ENet traffic using DTLS and certificates
extends Node

# EXPERT NOTE: DTLS provides encryption over UDP, 
# preventing man-in-the-middle attacks on sensitive data.

func secure_server(crypto_key: CryptoKey, cert: X509Certificate):
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(7000)
	
	# Setting up the TLS/DTLS options for the host
	var server_options := TLSOptions.server(crypto_key, cert)
	peer.host.dtls_server_setup(server_options)
	
	multiplayer.multiplayer_peer = peer
