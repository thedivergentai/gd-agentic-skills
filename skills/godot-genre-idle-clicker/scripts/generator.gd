# skills/genre-idle-clicker/scripts/generator.gd
extends Resource

## Generator Resource (Expert Pattern)
## Represents a purchasable producer (e.g., Grandma, Mine).
## Calculates cost scaling exponentially.

class_name Generator

@export var id: String
@export var name: String
@export var base_cost_mantissa: float = 10.0
@export var base_cost_exponent: int = 0
@export var base_revenue_mantissa: float = 1.0
@export var base_revenue_exponent: int = 0
@export var cost_growth_factor: float = 1.15

var count: int = 0

func get_cost() -> BigNumber:
    var growth_mult = pow(cost_growth_factor, count)
    var base = BigNumber.new(base_cost_mantissa, base_cost_exponent)
    return base.multiply(growth_mult)

func get_revenue_per_second() -> BigNumber:
    var base = BigNumber.new(base_revenue_mantissa, base_revenue_exponent)
    # Revenue = Base * Count (* Modifiers eventually)
    return base.multiply(float(count))

func purchase() -> void:
    count += 1

## EXPERT USAGE:
## Create .tres files for each generator.
## Use get_cost() to check affordability, purchase() to increment.
