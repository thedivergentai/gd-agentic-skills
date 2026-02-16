> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Economy Systems**. Accessed via Godot Master.

# Economy System

Expert guidance for designing balanced game economies, including currency management, dynamic shop pricing, and weighted loot tables.

## Available Scripts

### [loot_table_weighted.gd](../scripts/economy_system_loot_table_weighted.gd)
Weighted loot table implementation using cumulative probability. Resource-based design allows designers to adjust drop rates directly from the Inspector.


## NEVER Do

- **NEVER use `int` for global economy calculations** — While `int` works for small games, large economies with high multipliers should use `float` or a custom `BigInt` to prevent integer overflow (max 2.1B).
- **NEVER allow a 1:1 buy/sell price ratio** — This creates an infinite money exploit. Maintain a "spread" where selling items returns significantly less (standard 30-50%) than the purchase price.
- **NEVER skip currency sinks** — Without continuous "sinks" (e.g., equipment repairs, consumables, travel costs, taxes), players will hoard infinite wealth, causing hyperinflation.
- **NEVER hardcode loot table chances** — Use `Resource`-based weighted tables so drop rates can be tweaked without recompiling or editing core logic.

---

## Currency Management (Wallet Pattern)
Use an AutoLoad `EconomyManager` to track all player currencies. This ensures that money is persisted across scene transitions and provides a single source of truth for all transaction validation.

## Shop Systems
### Buy/Sell Logic
Validate `has_currency()` and `spend_currency()` on the Manager before modifying inventories.
- **Buy Price**: The fixed or dynamic cost to acquire an item.
- **Sell Price**: Typically a fraction of the buy price, optionally influenced by player "Barter" stats.

### Dynamic Pricing
Implement supply and demand by adjusting prices based on player trade volume. 
`price = base_price * (1.0 + demand_offset)`

## Loot Systems (Weighted Drops)
1. **Define Items**: Individual resources with rarity tiers.
2. **Loot Table**: A resource containing a list of items and their relative "Weight."
3. **Roll Logic**: Sum the weights, pick a random number between 0 and total, then iterate through the list to find the matching item.

## Rarity Tiers
Standardize item rarity using an `enum`: `COMMON`, `UNCOMMON`, `RARE`, `EPIC`, `LEGENDARY`. Each tier should have a color code and a base price multiplier associated with it.

## Reference
- [Godot Docs: Weighted Random Selection](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html#weighted-random-selection)
- [Godot Docs: Resource-based UI](https://docs.godotengine.org/en/stable/tutorials/ui/ui_design_with_resources.html)
