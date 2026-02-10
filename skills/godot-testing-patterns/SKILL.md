---
name: godot-testing-patterns
description: "Expert blueprint for testing patterns using GUT (Godot Unit Test), integration tests, mock/stub patterns, async testing, and validation techniques. Covers assert patterns, signal testing, and CI/CD integration. Use when implementing tests OR validating game logic. Keywords GUT, unit test, integration test, assert, mock, stub, GutTest, watch_signals, TDD."
---

# Testing Patterns

GUT framework, assertion patterns, mocking, and async testing define automated validation.

## Available Scripts

### [integration_test_base.gd](scripts/integration_test_base.gd)
Base class for GUT integration tests with auto-cleanup and scene helpers.

### [headless_test_runner.gd](scripts/headless_test_runner.gd)
Expert headless test runner for CI/CD with JUnit XML output and exit code handling.

## NEVER Do in Testing

- **NEVER test implementation details** — `assert_eq(player._internal_state, 5)`? Private variables = brittle tests. Test PUBLIC behavior, not internals.
- **NEVER share state between tests** — Test 1 modifies global variable, test 2 assumes clean state? Flaky tests. Use `before_each()` for fresh setup.
- **NEVER use sleep() for timing** — `await get_tree().create_timer(1.0).timeout` in tests? Slow + unreliable. Use GUT's `wait_seconds()` OR manual frame stepping.
- **NEVER skip cleanup in after_each()** — Test spawns 100 nodes, doesn't free? Memory leak + slow test suite. ALWAYS free nodes in `after_each()`.
- **NEVER test randomness without seeding** — `randi()` in test = non-deterministic failure. Use `seed(12345)` for repeatable tests.
- **NEVER forget to watch signals** — `assert_signal_emitted(obj, "died")` without `watch_signals`? Fails silently. MUST call `watch_signals(obj)` first.

---

### Installation

1. Download from AssetLib: "GUT - Godot Unit Test"
2. Enable in Project Settings → Plugins
3. Create `res://test/` directory

### Basic Test

```gdscript
# test/test_player.gd
extends GutTest

var player: CharacterBody2D

func before_each() -> void:
    player = preload("res://entities/player/player.tscn").instantiate()
    add_child(player)

func after_each() -> void:
    player.queue_free()

func test_initial_health() -> void:
    assert_eq(player.health, 100, "Player should start with 100 health")

func test_take_damage() -> void:
    player.take_damage(25)
    assert_eq(player.health, 75, "Health should be 75 after 25 damage")

func test_cannot_have_negative_health() -> void:
    player.take_damage(200)
    assert_gte(player.health, 0, "Health should not go below 0")
```

### Running Tests

```gdscript
# Via GUT panel in editor
# Or command line:
# godot --headless -s addons/gut/gut_cmdln.gd
```

## Assertion Patterns

```gdscript
# Equality
assert_eq(actual, expected, "message")
assert_ne(actual, not_expected, "message")

# Comparison
assert_gt(value, min_value, "should be greater")
assert_lt(value, max_value, "should be less")
assert_gte(value, min_value, "should be >= min")
assert_lte(value, max_value, "should be <= max")

# Boolean
assert_true(condition, "should be true")
assert_false(condition, "should be false")

# Null
assert_not_null(object, "should exist")
assert_null(object, "should be null")

# Arrays
assert_has(array, element, "should contain element")
assert_does_not_have(array, element, "should not contain")

# Signals
watch_signals(object)
assert_signal_emitted(object, "signal_name")
```

## Testing Signals

```gdscript
func test_death_signal() -> void:
    watch_signals(player)
    
    player.take_damage(100)
    
    assert_signal_emitted(player, "died")
    assert_signal_emitted_with_parameters(player, "died", [player])
```

## Testing Async

```gdscript
func test_delayed_action() -> void:
    player.start_ability()
    
    # Wait for timer
    await wait_seconds(1.0)
    
    assert_true(player.ability_active, "Ability should be active after delay")
```

## Mock/Stub Patterns

```gdscript
# Double (mock) pattern
func test_with_mock() -> void:
    var mock_enemy := double(Enemy).new()
    stub(mock_enemy, "get_damage").to_return(50)
    
    player.collide_with(mock_enemy)
    
    assert_eq(player.health, 50, "Should take mocked damage")
```

## Integration Testing

```gdscript
# test/test_combat_system.gd
extends GutTest

func test_player_kills_enemy() -> void:
    var level := preload("res://levels/test_arena.tscn").instantiate()
    add_child(level)
    
    var player := level.get_node("Player")
    var enemy := level.get_node("Enemy")
    
    # Simulate combat
    for i in range(5):
        player.attack(enemy)
        await wait_frames(1)
    
    assert_true(enemy.is_dead, "Enemy should be dead")
    assert_gt(player.score, 0, "Player should have score")
    
    level.queue_free()
```

## Manual Testing Checklist

```markdown
## Gameplay
- [ ] Player can move in all directions
- [ ] Jump height feels right
- [ ] Enemies respond to player
- [ ] Damage numbers are correct

## UI
- [ ] All buttons work
- [ ] Text is readable
- [ ] Responsive on different resolutions

## Audio
- [ ] Music plays
- [ ] SFX trigger correctly
- [ ] Volume levels balanced

## Performance
- [ ] Maintains 60 FPS
- [ ] No stuttering
- [ ] Memory stable
```

## Validation Helpers

```gdscript
# validation.gd (for runtime checks)
class_name Validation

static func assert_valid_health(health: int) -> void:
    assert(health >= 0 and health <= 100, "Invalid health: %d" % health)

static func assert_valid_position(pos: Vector2, bounds: Rect2) -> void:
    assert(bounds.has_point(pos), "Position out of bounds: %s" % pos)
```

## Test Organization

```
test/
├── unit/
│   ├── test_player.gd
│   ├── test_enemy.gd
│   └── test_inventory.gd
├── integration/
│   ├── test_combat.gd
│   └── test_save_load.gd
└── fixtures/
    ├── test_level.tscn
    └── mock_data.tres
```

## Best Practices

### 1. Test Edge Cases

```gdscript
func test_edge_cases() -> void:
    player.take_damage(0)  # Zero damage
    assert_eq(player.health, 100)
    
    player.take_damage(-10)  # Negative (heal?)
    assert_eq(player.health, 100)  # Should not change
```

### 2. Isolate Tests

```gdscript
# Each test should be independent
func before_each() -> void:
    # Fresh setup for each test
    player = create_fresh_player()
```

### 3. Test Critical Paths First

```
Priority:
1. Core gameplay (movement, combat)
2. Save/load system
3. Level transitions
4. UI interactions
```

## Reference
- [GUT Documentation](https://github.com/bitwes/Gut)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
