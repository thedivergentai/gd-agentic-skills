# skills/genre-sandbox/scripts/cellular_automata_liquid.gd
extends Node

## Cellular Automata Liquid (Expert Pattern)
## Logic for falling sand/water simulation in a grid.
## NOT a Node that enters the scene tree per cell, but a logic handler.

class_name CellularAutomataLiquid

const TYPE_EMPTY = 0
const TYPE_SAND = 1
const TYPE_WATER = 2
const TYPE_WALL = 3

static func simulate_grid(grid: Dictionary, width: int, height: int, dirty_cells: Array) -> void:
    # Sort dirty cells bottom-up, to process floor first. 
    # Actually for falling sand, we want to process BOTTOM UP so a falling stack moves together?
    # No, iterating bottom-up allows a grain to fall into the empty space created by the grain below it moving?
    # Actually, standard is: Iterate bottom-up.
    
    # Simple sort for example (Optimization: Use a proper dirty rect or active list)
    dirty_cells.sort_custom(func(a,b): return a.y > b.y) # Higher Y is lower on screen usually, check coord system
    # Assuming Y+ is Down. 
    
    var processed = {} # Prevent double moves
    
    for pos in dirty_cells:
        if processed.has(pos): continue
        
        var type = grid.get(pos, TYPE_EMPTY)
        if type == TYPE_SAND:
            _update_sand(grid, pos, processed)
        elif type == TYPE_WATER:
            _update_water(grid, pos, processed)

static func _update_sand(grid: Dictionary, pos: Vector2i, processed: Dictionary) -> void:
    var down = pos + Vector2i(0, 1)
    if not grid.has(down): # Empty
        _move(grid, pos, down, processed)
    else:
        var down_left = pos + Vector2i(-1, 1)
        var down_right = pos + Vector2i(1, 1)
        # Random disperse
        var moves = [down_left, down_right]
        moves.shuffle()
        for m in moves:
            if not grid.has(m):
                _move(grid, pos, m, processed)
                return

static func _update_water(grid: Dictionary, pos: Vector2i, processed: Dictionary) -> void:
    var down = pos + Vector2i(0, 1)
    if not grid.has(down):
        _move(grid, pos, down, processed)
        return
        
    # Flow sideways
    var left = pos + Vector2i(-1, 0)
    var right = pos + Vector2i(1, 0)
    var moves = [left, right]
    moves.shuffle()
    for m in moves:
        if not grid.has(m):
             _move(grid, pos, m, processed)
             return

static func _move(grid: Dictionary, from: Vector2i, to: Vector2i, processed: Dictionary) -> void:
    var type = grid[from]
    grid.erase(from)
    grid[to] = type
    processed[to] = true
    # Note: This simple dict approach is not performant for 100k cells.
    # Use PackedByteArray and flat indexing for real implementations.

## EXPERT USAGE:
## Call from _physics_process on the active chunk data.
