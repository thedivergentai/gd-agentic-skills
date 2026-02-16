# godot-master/scripts/gdscript_mastery_advanced_lambdas.gd
extends Node

## GDScript Mastery Expert Pattern
## Features Higher-Order Functions and Functional Composition.

func _ready() -> void:
    var numbers: Array[int] = [1, 2, 3, 4, 5, 6]
    
    # 1. Lambda Filtering & Mapping
    var evens = numbers.filter(func(n): return n % 2 == 0)
    var doubled = evens.map(func(n): return n * 2)
    
    # 2. Higher-Order Function (Function returning a Callable)
    var multiplier_for_3 = make_multiplier(3)
    print(multiplier_for_3.call(10)) # Outputs 30

## Returns a lambda that multiplies input by 'factor'
func make_multiplier(factor: float) -> Callable:
    return func(value): return value * factor

## 3. Typed Array Composition
## Experts use typed arrays to ensure the compiler can optimize loops.
func process_entities(entities: Array[Node2D], processor: Callable) -> void:
    for entity in entities:
        if is_instance_valid(entity):
            processor.call(entity)

## EXPERT NOTE:
## Use '@static' for utility functions that don't need instance state.
## This allows the engine to call them without allocating object memory.
static func calculate_distance_sq(a: Vector2, b: Vector2) -> float:
    return a.distance_squared_to(b)
