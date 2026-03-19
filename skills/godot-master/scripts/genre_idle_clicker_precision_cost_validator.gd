# precision_cost_validator.gd
extends Node

# Precision-Safe Cost Validation
# Accounts for IEEE 754 precision loss when comparing floating-point economy values.
func can_afford(currency: float, cost: float) -> bool:
    # is_equal_approx prevents scenarios where 100.0000001 vs 100.0 causes a failed purchase.
    # Pattern: Exact equality is unreliable; use approx or greater-than threshold.
    return currency > cost or is_equal_approx(currency, cost)
