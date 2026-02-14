> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Testing Patterns**. Accessed via Godot Master.

# Testing Patterns

Expert blueprint for automated validation in Godot using the GUT (Godot Unit Test) framework, including unit, integration, and async testing strategies.

## Available Scripts

### [integration_test_base.gd](../scripts/godot-testing-patterns_integration_test_base.gd)
Base class for complex integration tests. Includes automated scene cleanup, fixture loading helpers, and boilerplate for testing multi-node interactions.

### [headless_test_runner.gd](../scripts/godot-testing-patterns_headless_test_runner.gd)
Command-line utility for running GUT tests in a headless environment. Ideal for CI/CD pipelines (GitHub Actions/GitLab CI) with JUnit XML report output.


## NEVER Do

- **NEVER test private implementation details** — Testing `_internal_variable` makes your code fragile. Only test the public API and observable behaviors of your nodes.
- **NEVER share state between test methods** — If Test A modifies a singleton, Test B might fail unexpectedly. Always reset your environment in `before_each()` to ensure isolation.
- **NEVER use `OS.delay_msec()` or `Timer` nodes for test timing** — These are unreliable and slow. Use GUT's built-in `wait_seconds()` or `wait_frames()` for deterministic async testing.
- **NEVER skip node cleanup in `after_each()`** — Tests that instantiate nodes without freeing them will lead to memory leaks and eventually slow down the entire suite.
- **NEVER test random logic without a fixed seed** — Random failures are a nightmare. Use `seed(integer)` at the start of a test to ensure repeatable, deterministic results.
- **NEVER forget to call `watch_signals()`** — Signals won't be recorded by the test runner unless you explicitly tell GUT to watch the target object first.

---

## GUT Basics
1. **Extend `GutTest`**: All test scripts must extend this base class.
2. **Method Names**: Only methods starting with `test_` are executed by the runner.
3. **Assertions**: Use `assert_eq()`, `assert_true()`, `assert_not_null()`, etc., to validate outcomes.

## Unit vs. Integration Testing
- **Unit Testing**: Testing a single script or resource in isolation (e.g., Damage calculation logic).
- **Integration Testing**: Testing how multiple components work together (e.g., Player attacking an Enemy in a Level).

## Mocking & Doubling
Use GUT's `double()` and `stub()` functions to create fake versions of complex dependencies. 
- `var mock = double(Enemy).new()`
- `stub(mock, "take_damage").to_return(true)`
This allows you to test the Player's attack logic without needing a fully functional Enemy script.

## Signal Testing Workflow
1. `watch_signals(object)`
2. `object.do_something()`
3. `assert_signal_emitted(object, "done")`
4. `assert_signal_emitted_with_parameters(object, "done", [expected_arg])`

## Headless Testing (CI/CD)
Run your tests from the terminal to automate quality checks before every commit:
`godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test/ -ginclude_subdirs`

## Reference
- [GUT Wiki: Official Documentation](https://github.com/bitwes/Gut/wiki)
- [Godot Docs: Unit Testing](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/unit_testing.html)
