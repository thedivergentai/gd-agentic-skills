# skills/genre-idle-clicker/scripts/big_number.gd
class_name BigNumber
extends RefCounted

## Big Number System (Expert Pattern)
## Handles numbers larger than double-precision floats using (Mantissa, Exponent).
## e.g., 1.23e50

var mantissa: float = 0.0
var exponent: int = 0

func _init(m: float = 0.0, e: int = 0) -> void:
    mantissa = m
    exponent = e
    normalize()

func normalize() -> void:
    if mantissa == 0.0:
        exponent = 0
        return
        
    while abs(mantissa) >= 10.0:
        mantissa /= 10.0
        exponent += 1
        
    while abs(mantissa) < 1.0 and mantissa != 0.0:
        mantissa *= 10.0
        exponent -= 1

# Operations
func add(other: BigNumber) -> BigNumber:
    var diff = exponent - other.exponent
    if abs(diff) > 15:
        # If difference requires >15 digits precision shift, smaller number is negligible
        if diff > 0: return BigNumber.new(mantissa, exponent)
        else: return BigNumber.new(other.mantissa, other.exponent)
        
    var new_mantissa = mantissa + other.mantissa * pow(10, -diff)
    return BigNumber.new(new_mantissa, exponent) # Normalize happens in init

func multiply(scalar: float) -> BigNumber:
    return BigNumber.new(mantissa * scalar, exponent)
    
func multiply_bn(other: BigNumber) -> BigNumber:
    return BigNumber.new(mantissa * other.mantissa, exponent + other.exponent)

func to_string_formatted() -> String:
    if exponent < 3:
        return str(int(mantissa * pow(10, exponent)))
    elif exponent < 6:
         return "%.2fK" % (mantissa * pow(10, exponent - 3))
    elif exponent < 9:
         return "%.2fM" % (mantissa * pow(10, exponent - 6))
    else:
        return "%.2fe%d" % [mantissa, exponent]

## EXPERT USAGE:
## var cost = BigNumber.new(1.5, 12) # 1.5 Trillion
## var new_cost = cost.multiply(1.15)
