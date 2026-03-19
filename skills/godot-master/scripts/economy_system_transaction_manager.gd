# skills/economy-system/scripts/transaction_manager.gd
extends Node

## Transaction Manager Expert Pattern
## Safe atomic transactions for in-game economy (shops, trades).

class_name TransactionManager

signal transaction_completed(type: String, amount: int, item: String)
signal transaction_failed(reason: String)

enum CurrencyType { GOLD, GEMS, TOKENS }

var _wallets: Dictionary = {
	CurrencyType.GOLD: 0,
	CurrencyType.GEMS: 0
}

func get_balance(currency: CurrencyType) -> int:
	return _wallets.get(currency, 0)

func add_currency(currency: CurrencyType, amount: int) -> void:
	_wallets[currency] = get_balance(currency) + amount
	transaction_completed.emit("earn", amount, "")

func attempt_purchase(cost: int, currency: CurrencyType, item_id: String, inventory_target: InventoryData = null) -> bool:
	# 1. Validation
	if cost < 0:
		transaction_failed.emit("Invalid cost")
		return false
		
	if get_balance(currency) < cost:
		transaction_failed.emit("Insufficient funds")
		return false
	
	# 2. Inventory Check (Atomic Step 1)
	if inventory_target:
		if not inventory_target.can_add_item(item_id):
			transaction_failed.emit("Inventory full")
			return false
	
	# 3. Execution (Atomic Step 2)
	_wallets[currency] -= cost
	
	if inventory_target:
		inventory_target.add_item_by_id(item_id)
	
	transaction_completed.emit("spend", cost, item_id)
	return true

func attempt_sell(item_id: String, price: int, currency: CurrencyType, inventory_source: InventoryData) -> bool:
	# 1. Validation
	if not inventory_source.has_item(item_id):
		transaction_failed.emit("Item not found")
		return false
	
	# 2. Execution
	inventory_source.remove_item_by_id(item_id)
	add_currency(currency, price)
	
	transaction_completed.emit("sell", price, item_id)
	return true

## EXPERT USAGE:
## if TransactionManager.attempt_purchase(50, CurrencyType.GOLD, "sword_01", player_inv):
##     play_sound("kaching")
