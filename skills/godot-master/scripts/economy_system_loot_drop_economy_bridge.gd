# loot_drop_economy_bridge.gd
# Hooking combat drops to wallet addition
extends Node

# EXPERT NOTE: Use a generic node to listen for "Gold Drops" from enemies 
# to keep the combat system focused only on health/damage.

func _on_enemy_looted(gold_amount: int):
	WalletManager.add_funds("gold", gold_amount)
	print("Looted ", gold_amount, " gold.")
