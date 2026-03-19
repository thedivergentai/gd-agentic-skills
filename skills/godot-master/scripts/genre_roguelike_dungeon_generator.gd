# skills/genre-roguelike/scripts/dungeon_generator.gd
extends Node

## Dungeon Generator (Expert Pattern)
## Implements a walker-based procedural generation algorithm.
## Creates organic, connected layouts suitable for roguelikes.

class_name DungeonGenerator

signal generation_complete(rooms: Array, spawn_point: Vector2)

@export var tile_map: TileMapLayer
@export var map_width: int = 50
@export var map_height: int = 50
@export var max_walkers: int = 5
@export var max_steps: int = 400
@export var room_chance: float = 0.2

var rng: RandomNumberGenerator

func generate(seed_val: int) -> void:
    rng = RandomNumberGenerator.new()
    rng.seed = seed_val
    
    tile_map.clear()
    
    var start_pos = Vector2i(map_width / 2, map_height / 2)
    var floor_tiles: Array[Vector2i] = [start_pos]
    var walkers: Array[Vector2i] = [start_pos]
    
    # Drunkard's Walk
    for i in range(max_steps):
        var new_walkers: Array[Vector2i] = []
        for walker in walkers:
            # Move
            var dir = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
            var move = dir[rng.randi() % 4]
            var new_pos = walker + move
            
            # Clamp to bounds
            new_pos.x = clamp(new_pos.x, 2, map_width - 2)
            new_pos.y = clamp(new_pos.y, 2, map_height - 2)
            
            if new_pos not in floor_tiles:
                floor_tiles.append(new_pos)
            
            # Fork/Kill logic
            if rng.randf() < 0.2 and walkers.size() < max_walkers:
                new_walkers.append(new_pos) # Clone walker
                new_walkers.append(new_pos)
            elif rng.randf() < 0.05 and walkers.size() > 1:
                pass # Kill walker
            else:
                new_walkers.append(new_pos) # Keep walking
        
        walkers = new_walkers
        if walkers.is_empty(): # Safety
            walkers.append(floor_tiles.pick_random())

    # Set Tiles
    for pos in floor_tiles:
        tile_map.set_cell(pos, 0, Vector2i(0, 0)) # Assuming Atlas 0, Coords 0,0 is Floor
        
    # Post-Processing: Walls
    _generate_walls(floor_tiles)
    
    generation_complete.emit(floor_tiles, Vector2(start_pos) * tile_map.tile_set.tile_size.x)

func _generate_walls(floor_tiles: Array[Vector2i]) -> void:
    # Helper to surround floors with walls
    # (Simplified for example)
    pass

## EXPERT USAGE:
## Call generate(seed). Use generated floor_tiles to spawn enemies/loot.
