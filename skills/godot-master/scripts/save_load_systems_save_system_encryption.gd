# godot-master/scripts/save_load_systems_save_system_encryption.gd
extends Node

## Save System Encryption Expert Pattern
## Encrypted save files with AES-256 and optional compression.

class_name SaveSystemEncryption

const ENCRYPTION_KEY := "your-32-character-key-here!!"  # 32 bytes for AES-256
const SAVE_PATH := "user://savegame.enc"

func save_encrypted(data: Dictionary) -> bool:
	var json_string := JSON.stringify(data)
	var buffer := json_string.to_utf8_buffer()
	
	# Optional: Compress
	var compressed := buffer.compress(FileAccess.COMPRESSION_DEFLATE)
	
	# Encrypt with AES-256
	var ctx := AESContext.new()
	var key := ENCRYPTION_KEY.to_utf8_buffer()
	ctx.start(AESContext.MODE_ECB_ENCRYPT, key)
	
	var encrypted := ctx.update(compressed)
	ctx.finish()
	
	# Save to file
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false
		
	file.store_buffer(encrypted)
	file.close()
	return true

func load_encrypted() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
		
	var encrypted := file.get_buffer(file.get_length())
	file.close()
	
	# Decrypt
	var ctx := AESContext.new()
	var key := ENCRYPTION_KEY.to_utf8_buffer()
	ctx.start(AESContext.MODE_ECB_DECRYPT, key)
	
	var compressed := ctx.update(encrypted)
	ctx.finish()
	
	# Decompress
	var buffer := compressed.decompress_dynamic(-1, FileAccess.COMPRESSION_DEFLATE)
	
	# Parse JSON
	var json_string := buffer.get_string_from_utf8()
	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse decrypted save data")
		return {}
	
	return json.data

## EXPERT NOTES:
## - ENCRYPTION_KEY should be generated per project, store securely
## - Use CryptoKey for better key management  
## - This prevents casual save editing, NOT determined attackers
## - For multiplayer/leaderboards, validate server-side
