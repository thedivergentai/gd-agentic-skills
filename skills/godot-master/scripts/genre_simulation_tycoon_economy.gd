# skills/genre-simulation/scripts/tycoon_economy.gd
extends Node

## Tycoon Economy Manager (Expert Pattern)
## Handles multi-resource economy with caps, income/expense tracking, and bankruptcy.

class_name TycoonEconomy

signal resource_changed(type: String, current: float, max: float)
signal bankrupty_warning

var resources: Dictionary = {
    "money": 1000.0,
    "materials": 0.0,
    "energy": 100.0
}

var caps: Dictionary = {
    "money": 999999.0,
    "materials": 500.0,
    "energy": 200.0
}

func modify_resource(type: String, amount: float) -> bool:
    if not resources.has(type):
        return false
        
    var current = resources[type]
    
    # Check bankruptcy
    if type == "money" and current + amount < 0:
        bankrupty_warning.emit()
        return false # Or true if you allow debt
        
    var new_val = clamp(current + amount, 0, caps.get(type, 999999.0))
    resources[type] = new_val
    
    resource_changed.emit(type, new_val, caps.get(type, 999999.0))
    return true

func get_resource(type: String) -> float:
    return resources.get(type, 0.0)

## EXPERT USAGE:
## Autoload or instantiate in Main Scene.
## Connect UI to 'resource_changed' for live updates.
