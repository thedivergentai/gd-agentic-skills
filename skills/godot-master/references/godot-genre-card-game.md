> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Card Game**. Accessed via Godot Master.

# Genre: Card Game

Expert blueprint for building digital CCGs, TCGs, and Roguelike Deck-builders. Focuses on data-driven card Resource design, hand layout math (arcs), and complex effect resolution stacks.

## Available Scripts

### [card_effect_resolution.gd](../scripts/godot-genre-card-game_card_effect_resolution.gd)
A sophisticated stack-based effect resolver (Command Pattern). Handles nested triggers, "reaction" or "counter" cards (Last-In-First-Out logic), and provides hooks for visual pass animations between effect steps.


## NEVER Do

- **NEVER hardcode specific card logic inside the Card UI script** — The UI script should only handle dragging and hovering. The actual gameplay logic (e.g., "Deal 10 Damage") should be encapsulated in a `Command` object or an `effect_script` Resource.
- **NEVER use `global_position` for cards in hand** — Hand cards should be positioned relative to a `Control` container. Using global coordinates makes the hand layout break whenever the parent UI or camera moves.
- **NEVER forget to handle empty deck scenarios** — In most card games, when the Draw Pile is empty, you must automatically reshuffle the Discard Pile. Forgetting this logic causes the game to soft-lock when the player runs out of cards.
- **NEVER skip Z-Index management during drag-and-drop** — If you don't raise the `z_index` of a card while it's being dragged, it will slide *under* other cards or UI elements, which looks unprofessional. Always call `move_to_front()` or increase `z_index` on `InputEventMouseButton`.
- **NEVER allow instant card "teleportation" between piles** — Digital card games rely heavily on "Game Feel." Moving a card from the deck to the hand without at least a 0.2s `Tween` animation makes the game feel flat and digital rather than tangible.
- **NEVER perform board-state calculations in `_process()`** — Card game logic is event-driven. Recalculations (like Power/Toughness buffs) should only trigger when a card is played, a unit dies, or a phase changes.

---

## Data-Driven Cards (Resources)
Define your cards as `Resource` files (.tres):
- `title: String`
- `cost: int`
- `description: String`
- `effect_resource: CardEffect` (A script/resource defining the action).

## Hand Layout: The Arcade Arc
To create a "fan" of cards:
1. Calculate the center of your hand container.
2. Position cards on an imaginary circle:
   ```gdscript
   x = center.x + radius * sin(angle)
   y = center.y - radius * cos(angle)
   ```
3. Rotate each card based on its index: `rotation = (index - total / 2) * step_angle`.

## Effect Resolution Stack
For games with reactions (like *Magic: The Gathering*):
- Use a `Last-In-First-Out` (LIFO) stack.
- When a card is played, it's added to the top of the stack.
- Each player gets a chance to "respond" with their own card.
- Resolve from top to bottom.

## Drag and Drop Pattern
- **Hover State**: Scale up the card and play a "zoom" animation.
- **Drag State**: Card follows mouse. Highlight valid targets (Enemy, Ally, or Board).
- **Drop State**: If over a valid target, play the card. If not, Tween the card back to its hand position.

## Reference
- [Godot Docs: Drag and Drop UI](https://docs.godotengine.org/en/stable/tutorials/ui/drag_and_drop.html)
- [GDC: The Visual Language of Card Games](https://www.youtube.com/watch?v=N_pE0O6X5F0)
