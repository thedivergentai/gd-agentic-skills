> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Action RPG**. Accessed via Godot Master.

# Genre: Action RPG

Expert blueprint for building high-fidelity Action RPGs (top-down or 3rd person). Covers real-time combat (hitbox/hurtbox), attribute-based progression, procedural loot generation, and advanced enemy AI telegraphing.

## Available Scripts

### [damage_label_manager.gd](../scripts/godot-genre-action-rpg_damage_label_manager.gd)
A high-performance, pooled system for floating damage numbers. Handles critical hit styling (scaling/shaking), vertical stacking logic to prevent overlapping, and automatic cleanup.

### [telegraphed_enemy.gd](../scripts/godot-genre-action-rpg_telegraphed_enemy.gd)
Advanced AI component for "souls-like" or "telegraphed" combat. Manages the wind-up animations, visual indicators (AOE circles/cones), and timed execution of dangerous enemy attacks.


## NEVER Do

- **NEVER use linear damage scaling for progression** — Using `damage = level * 10` makes late-game power spikes feel underwhelming. Use an exponential curve (e.g., `base * pow(1.15, level)`) to maintain the "power fantasy" as players progress.
- **NEVER hide critical stats from the player** — Obfuscating information like "Crit Chance %" or "Damage Resistance" makes players feel ignored and prevents theory-crafting. Always provide a detailed character sheet.
- **NEVER allow defense stats to stack linearly to 100%** — If armor subtracts a fixed amount of damage, players will eventually become invincible. Use a **Diminishing Returns** formula: `damage_reduction = armor / (armor + 100)`.
- **NEVER skip Hit Recovery (Stagger)** — If an enemy or player takes damage but doesn't react visually, the combat feels "floaty" or weightless. Implement a brief stagger state (0.2s - 0.5s) on significant hits.
- **NEVER make loot drops visually identical** — A common mistake in ARPG design is having a Legendary item look the same on the ground as a Common item. Use color-coded beams (purple/gold) and distinct sound cues for high-rarity drops.
- **NEVER calculate stats every frame** — Recalculating 50+ attributes in `_process()` is expensive. Only trigger stat recalculation when gear changes, a level-up occurs, or a passive skill is unlocked.

---

## Combat: Hitboxes vs. Hurtboxes
- **Hitbox**: The area that *causes* damage. Attached to weapons or projectiles.
- **Hurtbox**: The area that *receives* damage. Attached to the entity's body.
Use `Area2D` or `Area3D` nodes with specialized layers to prevent allies from damaging themselves.

## Procedural Loot Generation
Implement a `LootGenerator` that rolls:
1. **Rarity**: Weights for Common (60%), Rare (10%), Legendary (1%), etc.
2. **Base Type**: Sword, Axe, Staff (determines base stats and slot).
3. **Affixes**: Randomly rolled modifiers (e.g., "+10 STR", "+5% Fire Damage") based on the item level and rarity.

## Character Progression (RPGStats)
Centralize all stats in a `Resource` rather than hardcoding them on the player node.
- **Base Attributes**: Strength, Dexterity, Intelligence.
- **Derived Stats**: Max Health (VIT * 10), Crit Chance (DEX * 0.2).
- **Modifiers**: Flat (+50 HP) vs. Percent (+10% Attack Speed) bonuses from equipment.

## Enemy AI Design
Focus on "Telegraphed" patterns:
1. **Wind-up**: Show a particle effect or animation.
2. **Telegraph**: Draw a red circle or cone on the ground using `Polygon2D` or a specialized shader.
3. **Execution**: Enable the damaging hitbox.
4. **Recovery**: A short window where the enemy is vulnerable.

## Reference
- [Godot Docs: Area2D Combat](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [Diablo Theory: Scaling Damage & Armor](https://maxroll.gg/d3/resources/damage-mechanics)
