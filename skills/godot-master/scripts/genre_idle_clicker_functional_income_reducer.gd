# functional_income_reducer.gd
extends Node

# Functional Array Reduction (High-Performance Math)
# Uses fast internal C++ loops to sum income from thousands of generators.
func get_total_income(generator_counts: Array[int], income_per_unit: Array[float]) -> float:
    # Pattern: Map counts to income, then reduce to a single sum.
    # reduce(func(accumulator, value), initial_value)
    return generator_counts.reduce(func(total, current_count): 
        return total + (current_count * income_per_unit[generator_counts.find(current_count)]), 0.0)
