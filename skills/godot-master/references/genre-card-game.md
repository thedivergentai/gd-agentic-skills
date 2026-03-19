---
name: godot-genre-card-game
description: "Expert blueprint for digital card games (CCG/Deckbuilders) including card data structures (Resource-based), deck management (draw/discard/reshuffle), turn logic, hand layout (arcing), drag-and-drop UI, effect resolution (Command pattern), and visual polish (godot-tweening, shaders). Use for CCG, deckbuilders, or tactical card games. Trigger keywords: card_game, deck_manager, card_data, hand_layout, drag_drop_cards, effect_resolution, command_pattern, draw_pile, discard_pile."
---

# Genre: Card Game

Expert blueprint for digital card games with data-driven design and juicy UI.

## NEVER Do (Expert Anti-Patterns)

### Logic & Architecture
- NEVER hardcode card logic inside UI scripts; strictly encapsulate gameplay effects in **`Callable` objects** or **Command resources** pushed to a LIFO stack.
- NEVER perform board-state calculations (Power/Toughness) in `_process()`; strictly use **Signal-driven triggers** or a centralized `EffectStack` resolver.
- NEVER forget **LIFO Stack Resolution**; strictly use **`Array.push_back()`** and **`Array.pop_back()`** to resolve reactions from top-to-bottom.

### UX & Animation
- NEVER skip **Z-Index management** during drag-and-drop; strictly raise the card to the front on click to prevent it sliding under other cards.
- NEVER allow instant card "teleportation" between piles; strictly use **Tween animations** (0.2s+) to give cards a tactile, physical feel.
- NEVER use `global_position` for cards in hand; strictly position them using a **`Curve2D`** (Bezier) layout with **`sample_baked()`** for smooth, non-circular arcs.
- NEVER allow instant card "teleportation" between piles; strictly use **`create_tween()`** and **`tween_property`** chainings (0.2s+) for juicy card-feel.

### Deck & State Management
- NEVER forget to handle **Empty Deck** scenarios; strictly implement auto-reshuffle of the discard pile to prevent soft-locks.
- NEVER use floating point numbers for discrete card stats; strictly use `int` for Costs, Attack, and Health to avoid precision drift.
- NEVER use standard Control nodes for mass tokens/battlefields; strictly use **`_draw()` custom drawing** to bypass SceneTree overhead when rendering 100+ cards or map icons.
- NEVER rely on SceneTree order for hand logic; strictly manage logical order in an **Array** and update visuals via **`queue_redraw()`**.
- NEVER erase array elements during a standard `for` loop; strictly iterate in reverse or use `filter()` to avoid indexing errors.
- NEVER forget to provide parameterless constructors in `_init()`; otherwise, Resources will fail to load in the Inspector.
---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [card_effect_resolution.gd](../scripts/genre_card_game_card_effect_resolution.gd) - Stack-based effect resolver (LIFO/FIFO) handling nested triggers and counter-play.

### Modular Components
- [card_data_resource.gd](../scripts/genre_card_game_card_data_resource.gd) - Data-driven card definitions allowing Inspector-based design.
- [deck_shuffle_bag.gd](../scripts/genre_card_game_deck_shuffle_bag.gd) - Secure randomization patterns for uniform card distribution.
- [turn_state_machine.gd](../scripts/genre_card_game_turn_state_machine.gd) - Managing rigid phases (Draw, Play, Combat) via state matching.
- [card_drag_drop.gd](../scripts/genre_card_game_card_drag_drop.gd) - Implementation of native `_get_drag_data()` for Control nodes.
- [board_query_filter.gd](../scripts/genre_card_game_board_query_filter.gd) - Functional `filter()` patterns for querying board metadata.
- [card_tween_manager.gd](../scripts/genre_card_game_card_tween_manager.gd) - Managing interruptible card juice and board transitions.
- [reactive_card_ui.gd](../scripts/genre_card_game_reactive_card_ui.gd) - Resource-signal driven UI for automatic visual state updates.
- [board_state_dictionary.gd](../scripts/genre_card_game_board_state_dictionary.gd) - Grid-based tracking (Vector2i) decoupled from Node order.
- [match_state_resetter.gd](../scripts/genre_card_game_match_state_resetter.gd) - Clean-up pattern for in-match temporary Resource modifications.
- [deck_builder_validator.gd](../scripts/genre_card_game_deck_builder_validator.gd) - Backend logic for deck-building constraints and mana curves.

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
- Master Skill: [godot-master](../SKILL.md)
