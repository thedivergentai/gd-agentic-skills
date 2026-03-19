class_name PlatformSDKWrapper
extends Node

## Expert wrapper for proprietary PC SDKs (Steam, Epic).
## Uses safety checks to prevent crashes when singletons are missing.

var _steam_api: Object = null

func _ready() -> void:
	if Engine.has_singleton("Steam"):
		_steam_api = Engine.get_singleton("Steam")
		var init = _steam_api.steamInit()
		if init.status == 1:
			print("Desktop: Steamworks Initialized.")
	else:
		print("Desktop: No Steam singleton found. Running in standalone mode.")

func unlock_achievement(id: String) -> void:
	if _steam_api and _steam_api.isSteamRunning():
		_steam_api.setAchievement(id)
		_steam_api.storeStats()

## Expert: Always check 'Engine.has_singleton' before any SDK call.
