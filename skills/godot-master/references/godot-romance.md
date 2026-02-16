# Romance & Affection Systems

Relationship-centric mechanics driven by the "Affection Economy"—resource/time management influencing NPC attraction, trust, and intimacy.

## The Core Loop
**Meet → Date → Deepen → Branch → Resolve**

## Why Multi-Axis Stats?
Naive systems use a single `affection` integer. This creates "vending machine" romance. 
**Expert Pattern**: Decouple **Attraction** (physical/chemistry), **Trust** (emotional safety), and **Comfort** (familiarity). This allows for complex dynamics (e.g., high attraction but zero trust).

## Implementation: The Affection Manager
Centralized singleton handling multi-dimensional stats and diminishing returns for gifts.

```gdscript
# romance_affection_manager.gd
func give_gift(character_id: String, item_data: Dictionary) -> int:
    var multiplier: float = max(0.2, 1.0 - (times_given * 0.2)) # Expert: Prevents spam
    var final_amount: int = int(ceil(item_data.get("value", 5) * multiplier))
    add_stat(character_id, RelationStat.ATTRACTION, final_amount)
    return final_amount
```

## Date Success Framework
Do not use binary pass/fail. Use weighted scoring based on location-personality alignment and variety enforcement.

*   **Weighted Scoring**: `score = (Attraction * ChemMod) + (Trust * SafetyMod) + ChoiceMods`
*   **Variety Enforcement**: Penalty (e.g., 30%) for repeating locations. Prevents the "Same Date Order" trap.

## Route Branching & CG Persistence
Persistent data must track "Route Locked" status and visual unlocks (CG Gallery) across playthroughs.

```gdscript
# romance_route_manager.gd
func determine_ending(character_id: String) -> EndingType:
    var stats = RomanceAffectionManager.get_stats(character_id)
    if stats["trust"] < 0: return EndingType.BAD
    if stats["attraction"] >= 80 and stats["trust"] >= 50: return EndingType.TRUE if stats["comfort"] >= 70 else EndingType.GOOD
    return EndingType.NORMAL
```

## Expert Gotchas
- **Opaque Failure**: Never fail a date without feedback. Use NPC dialogue to "telegraph" preferences (e.g., "I hate loud music...").
- **NPC Autonomy**: Character should be able to *reject* events if current relationship stats (like Trust) are below thresholds.
- **Route Conflict**: Implement jealousy or exclusivity flags in the `RouteManager` to prevent simultaneous conflicting routes without narrative consequence.

## See Also
- [Dialogue Systems](./dialogue_system.md)
- [Save/Load Systems](./save_load_systems.md)
