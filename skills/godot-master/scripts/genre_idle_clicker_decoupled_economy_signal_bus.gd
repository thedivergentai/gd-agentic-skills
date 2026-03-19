# decoupled_economy_signal_bus.gd
extends Node

# Decoupled Economy Signal Bus
# Ensures the internal simulation is completely independent from the visual UI layer.
signal currency_updated(total: float, delta: float)

var _total_currency: float = 0.0

func add_currency(amount: float) -> void:
    _total_currency += amount
    
    # Emit signal for any UI listeners to update themselves only when necessary.
    currency_updated.emit(_total_currency, amount)
