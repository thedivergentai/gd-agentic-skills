# currency_label_sync.gd
# Reactive UI for balance display
extends Label

@export var currency_id: String = "gold"

func _ready():
	WalletManager.balance_changed.connect(_on_balance_changed)
	text = str(WalletManager.balances.get(currency_id, 0))

func _on_balance_changed(id: String, amount: int):
	if id == currency_id:
		text = str(amount)
