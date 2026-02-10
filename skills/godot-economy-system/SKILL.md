---
name: godot-economy-system
description: "Expert patterns for game economies including currency management (multi-currency, wallet system), shop systems (buy/sell prices, stock limits), dynamic pricing (supply/demand), loot tables (weighted drops, rarity tiers), and economic balance (inflation control, currency sinks). Use for RPGs, trading games, or resource management systems. Trigger keywords: EconomyManager, currency, shop_item, loot_table, dynamic_pricing, buy_sell_spread, currency_sink, inflation, item_rarity."
---

# Economy System

Expert guidance for designing balanced game economies with currency, shops, and loot.

## NEVER Do

- **NEVER use `int` for currency** — Use `int` for small amounts, but `float` or custom BigInt for large economies. Integer overflow destroys economies (max 2.1B).
- **NEVER forget buy/sell price spread** — Selling for same price as buying creates infinite money loop. Sell price should be 30-50% of buy price.
- **NEVER skip currency sinks** — Without sinks (repairs, taxes, consumables), economy inflates. Players hoard unlimited wealth.
- **NEVER use client-side currency validation** — Client calculates "I have 1000 gold". Server validates all transactions or exploits occur.
- **NEVER hardcode loot drop chances** — Use Resources or JSON for loot tables. Designers need iteration without code changes.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [loot_table_weighted.gd](scripts/loot_table_weighted.gd)
Weighted loot table using cumulative probability. Resource-based design allows designer iteration via inspector without code changes.

---

## Currency Manager

```gdscript
# economy_manager.gd (AutoLoad)
extends Node

signal currency_changed(old_amount: int, new_amount: int)

var gold: int = 0

func add_currency(amount: int) -> void:
    var old := gold
    gold += amount
    currency_changed.emit(old, gold)

func spend_currency(amount: int) -> bool:
    if gold < amount:
        return false
    
    var old := gold
    gold -= amount
    currency_changed.emit(old, gold)
    return true

func has_currency(amount: int) -> bool:
    return gold >= amount
```

## Shop System

```gdscript
# shop_item.gd
class_name ShopItem
extends Resource

@export var item: Item
@export var buy_price: int
@export var sell_price: int
@export var stock: int = -1  # -1 = infinite

func can_buy() -> bool:
    return stock != 0
```

```gdscript
# shop.gd
class_name Shop
extends Resource

@export var shop_name: String
@export var items: Array[ShopItem] = []

func buy_item(shop_item: ShopItem, inventory: Inventory) -> bool:
    if not shop_item.can_buy():
        return false
    
    if not EconomyManager.has_currency(shop_item.buy_price):
        return false
    
    if not EconomyManager.spend_currency(shop_item.buy_price):
        return false
    
    inventory.add_item(shop_item.item, 1)
    
    if shop_item.stock > 0:
        shop_item.stock -= 1
    
    return true

func sell_item(item: Item, inventory: Inventory) -> bool:
    # Find matching shop item for sell price
    var shop_item := get_shop_item_for(item)
    if not shop_item:
        return false
    
    if not inventory.has_item(item, 1):
        return false
    
    inventory.remove_item(item, 1)
    EconomyManager.add_currency(shop_item.sell_price)
    return true

func get_shop_item_for(item: Item) -> ShopItem:
    for shop_item in items:
        if shop_item.item == item:
            return shop_item
    return null
```

## Pricing Formula

```gdscript
func calculate_sell_price(buy_price: int, markup: float = 0.5) -> int:
    # Sell for 50% of buy price
    return int(buy_price * markup)

func calculate_dynamic_price(base_price: int, demand: float) -> int:
    # Price increases with demand
    return int(base_price * (1.0 + demand))
```

## Loot Tables

```gdscript
# loot_table.gd
class_name LootTable
extends Resource

@export var drops: Array[LootDrop] = []

func roll_loot() -> Array[Item]:
    var items: Array[Item] = []
    
    for drop in drops:
        if randf() < drop.chance:
            items.append(drop.item)
    
    return items
```

```gdscript
# loot_drop.gd
class_name LootDrop
extends Resource

@export var item: Item
@export var chance: float = 0.5
@export var min_amount: int = 1
@export var max_amount: int = 1
```

## Best Practices

1. **Balance** - Test economy carefully
2. **Sinks** - Provide money sinks (repairs, etc.)
3. **Inflation** - Control money generation

## Reference
- Related: `godot-inventory-system`, `godot-save-load-systems`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
