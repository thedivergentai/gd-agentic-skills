---
name: godot-genre-card-game
description: "Expert blueprint for digital card games (CCG/Deckbuilders) including card data structures (Resource-based), deck management (draw/discard/reshuffle), turn logic, hand layout (arcing), drag-and-drop UI, effect resolution (Command pattern), and visual polish (godot-tweening, shaders). Use for CCG, deckbuilders, or tactical card games. Trigger keywords: card_game, deck_manager, card_data, hand_layout, drag_drop_cards, effect_resolution, command_pattern, draw_pile, discard_pile."
---

# Genre: Card Game

Expert blueprint for digital card games with data-driven design and juicy UI.

## NEVER Do

- **NEVER hardcode card effects in card scripts** — Use Command pattern or effect_script Resource. Enables designers to create cards without code.
- **NEVER use global_position for hand layout** — Hand cards should use local positions relative to hand container. global_position breaks with camera movement.
- **NEVER forget to shuffle discard into draw pile** — When draw_pile is empty, reshuffle discard_pile. Otherwise game soft-locks.
- **NEVER skip z_index management** — Dragged cards must have highest z_index. Use `move_to_front()` or set `z_index = 999`.
- **NEVER use instant card movements** — Cards without tween animations feel terrible. Even 0.2s tweens massively improve feel.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [card_effect_resolution.gd](scripts/card_effect_resolution.gd)
FILO stack for card effect resolution. Enables reaction/counter cards (last-in resolves first), visual pass for animations, and polymorphic effect dispatch.

---

## Core Loop
1.  **Draw**: Player draws cards from a deck into their hand.
2.  **Evaluate**: Player assesses board state, mana/energy, and card options.
3.  **Play**: Player plays cards to trigger effects (damage, buff, summon).
4.  **Resolve**: Effects occur immediately or go onto a stack.
5.  **Discard/End**: Unused cards are discarded (roguelike) or kept (TCG), turn ends.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Data | `resources`, `custom-resources` | Defining Card properties (Cost, Type, Effect) |
| 2. UI | `control-nodes`, `layout-containers` | Hand layout, card positioning, tooltips |
| 3. Input | `drag-and-drop`, `state-machines` | Dragging cards to targets, hovering |
| 4. Logic | `command-pattern`, `signals` | Executing card effects, turn phases |
| 5. Polish | `godot-tweening`, `shaders` | Draw animations, holographic foils |

## Architecture Overview

### 1. Card Data (Resource-based)
Godot Resources are perfect for card data.

```gdscript
# card_data.gd
extends Resource
class_name CardData

enum Type { ATTACK, SKILL, POWER }
enum Target { ENEMY, SELF, ALL_ENEMIES }

@export var id: String
@export var name: String
@export_multiline var description: String
@export var cost: int
@export var type: Type
@export var target_type: Target
@export var icon: Texture2D
@export var effect_script: Script # Custom logic per card
```

### 2. Deck Manager
Handles the piles: Draw Pile, Hand, Discard Pile, Exhaust Pile.

```gdscript
# deck_manager.gd
var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

func draw_cards(amount: int) -> void:
    for i in amount:
        if draw_pile.is_empty():
            reshuffle_discard()
            
        if draw_pile.is_empty(): 
            break # No cards left
            
        var card = draw_pile.pop_back()
        hand.append(card)
        card_drawn.emit(card)

func reshuffle_discard() -> void:
    draw_pile.append_array(discard_pile)
    discard_pile.clear()
    draw_pile.shuffle()
```

### 3. Card Visual (UI)
The interactive node representing a card in hand.

```gdscript
# card_ui.gd
extends Control

var card_data: CardData
var start_pos: Vector2
var is_dragging: bool = false

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            start_drag()
        else:
            end_drag()

func _process(delta: float) -> void:
    if is_dragging:
        global_position = get_global_mouse_position() - size / 2
    else:
        # Hover effect or return to hand position
        pass
```

## Key Mechanics Implementation

### Effect Resolution (Command Pattern)
Decouple the "playing" of a card from its "effect".

```gdscript
func play_card(card: CardData, target: Node) -> void:
    if current_energy < card.cost:
        show_error("Not enough energy")
        return
        
    current_energy -= card.cost
    
    # Execute effect
    var effect = card.effect_script.new()
    effect.execute(target)
    
    move_to_discard(card)
```

### Hand Layout (Arching)
Cards in hand usually form an arc. Use a math formula (Bezier or Circle) to position them based on `index` and `total_cards`.

```gdscript
func update_hand_visuals() -> void:
    var center_x = screen_width / 2
    var radius = 1000.0
    var angle_step = 5.0
    
    for i in hand_visuals.size():
        var card = hand_visuals[i]
        var angle = deg_to_rad((i - hand_visuals.size() / 2.0) * angle_step)
        var target_pos = Vector2(
            center_x + sin(angle) * radius,
            screen_height + cos(angle) * radius
        )
        card.target_rotation = angle
        card.target_position = target_pos
```

## Common Pitfalls

1.  **Complexity Overload**: Too many keywords. **Fix**: Stick to 3-5 core keywords (e.g., Taunt, Poison, Shield) and expand slowly.
2.  **Unreadable Text**: Tiny fonts on cards. **Fix**: Use icons for common stats (Damage, Block) and keep text short.
3.  **Animation Lock**: Waiting for slow animations to finish before playing the next card. **Fix**: Allow queueing actions or keep animations snappy (< 0.3s).

## Godot-Specific Tips

*   **MouseFilter**: Getting drag/drop to work with overlapping UI requires careful setup of `mouse_filter` (Pass vs Stop).
*   **Z-Index**: Use `z_index` or `CanvasLayer` to ensure the dragged card is always on top of everything else.
*   **Tweens**: Essential! Tween position, rotation, and scale for that "juicy" Hearthstone/Slay the Spire feel.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
