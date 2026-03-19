# economy_persistence_handler.gd
# Saving financial state securely
extends Node

# EXPERT NOTE: Save balances as a simple JSON-compatible dictionary. 
# Consider basic encryption for premium currency counts.

func save_economy() -> Dictionary:
	return WalletManager.balances.duplicate()

func load_economy(data: Dictionary):
	WalletManager.balances = data
	for id in data:
		WalletManager.balance_changed.emit(id, data[id])
