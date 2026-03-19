class_name NetRPCRateLimiter
extends Node

## Expert RPC Rate Limiting.
## Prevents malicious clients from flooding the server with expensive calls.

var rpc_timers: Dictionary = {}

func is_rate_limited(peer_id: int, rpc_name: String, limit_ms: float = 50.0) -> bool:
	var key = str(peer_id) + "_" + rpc_name
	var now = Time.get_ticks_msec()
	
	if rpc_timers.has(key) and (now - rpc_timers[key]) < limit_ms:
		return true
		
	rpc_timers[key] = now
	return false

## Tip: Use this for 'Fire', 'Reload', or 'Interact' RPCs to block macro users.
