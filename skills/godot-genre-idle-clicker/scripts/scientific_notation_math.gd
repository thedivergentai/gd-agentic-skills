# scientific_notation_math.gd
extends Node

# Scientific Notation Formatter (Scale Management)
# Handles display for astronomical clicker currencies exceeding standard float precision limits.
func format_large_value(value: float) -> String:
    # Switches to scientific notation after 1 Million.
    if value > 1_000_000.0:
        # String.num_scientific produces optimized "1.23e12" format natively.
        return String.num_scientific(value)
        
    # Standard string formatting for lower values.
    return str(snappedf(value, 0.01))
