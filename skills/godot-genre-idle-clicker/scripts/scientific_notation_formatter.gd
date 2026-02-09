# skills/genre-idle-clicker/code/scientific_notation_formatter.gd
extends Node

## Scientific Notation Formatter Expert Pattern
## Handles numbers up to 1e303 (Centillion) with human-readable suffixes.

const SUFFIXES = [
    "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
    "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc", "Vg"
]

func format_value(value: float) -> String:
    # 1. Standard Case
    if value < 1000:
        return str(floor(value))
        
    # 2. BigNum Logic
    var exponent = floor(log(value) / log(1000))
    var suffix_index = int(exponent)
    
    if suffix_index < SUFFIXES.size():
        var short_val = value / pow(1000, exponent)
        # Professional formatting: 3 significant digits (e.g. 1.23M)
        return "%.2f%s" % [short_val, SUFFIXES[suffix_index]]
    else:
        # 3. Scientific Fallback
        # Beyond Vigintillion, use standard scientific notation.
        var e_val = log(value) / log(10)
        return "%.2fe%d" % [value / pow(10, floor(e_val)), int(e_val)]

## EXPERT NOTE:
## For performance in idle games with 100+ labels, CACHE the result 
## and only re-calculate if the value has changed by > 1%.
## Use 'ColorRect' or 'Shader' for 'Damage Number' popups to avoid 
## Label-instance overhead during "Click Storms".
