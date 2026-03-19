# lightweight_upgrade_resource.gd
extends RefCounted
class_name ClickerUpgradeResource

# Lightweight RefCounted Data Structures
# Avoids the Node-tree overhead for non-visual upgrade logic.
var level: int = 0
var multiplier: float = 1.15
var base_cost: float = 10.0

func get_next_cost() -> float:
    # Standard idle scaling formula: cost * (growth ^ level)
    return base_cost * pow(multiplier, level)

func purchase() -> void:
    level += 1
