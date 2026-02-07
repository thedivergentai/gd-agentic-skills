# skills/procedural-generation/scripts/dungeon_generator.gd
extends Node2D

## Dungeon Generator Expert Pattern
## BSP-based room placement with FastNoiseLite for terrain variation.

class_name DungeonGenerator

@export var room_count := 10
@export var min_room_size := Vector2i(5, 5)
@export var max_room_size := Vector2i(12, 12)
@export var map_size := Vector2i(100, 100)

var noise := FastNoiseLite.new()
var rooms: Array[Rect2i] = []

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.05

func generate() -> Array[Rect2i]:
	rooms.clear()
	
	# BSP rectangle subdivision
	var initial_rect := Rect2i(Vector2i.ZERO, map_size)
	var partitions := [initial_rect]
	
	# Split into smaller partitions
	while partitions.size() < room_count:
		var partition: Rect2i = partitions.pick_random()
		partitions.erase(partition)
		
		var split_rects := _split_rect(partition)
		if split_rects.size() == 2:
			partitions.append_array(split_rects)
		else:
			partitions.append(partition)  # Couldn't split, keep it
	
	# Create rooms inside partitions
	for partition in partitions:
		var room := _create_room_in_partition(partition)
		if room.has_area():
			rooms.append(room)
	
	return rooms

func _split_rect(rect: Rect2i) -> Array[Rect2i]:
	# Can't split if too small
	if rect.size.x < min_room_size.x * 2 or rect.size.y < min_room_size.y * 2:
		return []
	
	var split_horizontal := randf() > 0.5
	
	if split_horizontal:
		var split_y := randi_range(rect.position.y + min_room_size.y, rect.end.y - min_room_size.y)
		return [
			Rect2i(rect.position, Vector2i(rect.size.x, split_y - rect.position.y)),
			Rect2i(Vector2i(rect.position.x, split_y), Vector2i(rect.size.x, rect.end.y - split_y))
		]
	else:
		var split_x := randi_range(rect.position.x + min_room_size.x, rect.end.x - min_room_size.x)
		return [
			Rect2i(rect.position, Vector2i(split_x - rect.position.x, rect.size.y)),
			Rect2i(Vector2i(split_x, rect.position.y), Vector2i(rect.end.x - split_x, rect.size.y))
		]

func _create_room_in_partition(partition: Rect2i) -> Rect2i:
	var room_w := randi_range(min_room_size.x, min(max_room_size.x, partition.size.x - 2))
	var room_h := randi_range(min_room_size.y, min(max_room_size.y, partition.size.y - 2))
	
	var room_x := partition.position.x + randi_range(1, partition.size.x - room_w - 1)
	var room_y := partition.position.y + randi_range(1, partition.size.y - room_h - 1)
	
	return Rect2i(room_x, room_y, room_w, room_h)

func get_noise_value_at(pos: Vector2i) -> float:
	return noise.get_noise_2d(float(pos.x), float(pos.y))

## EXPERT USAGE:
## var gen := DungeonGenerator.new()
## gen.room_count = 15
## add_child(gen)
## var rooms := gen.generate()
## 
## # Use rooms to place tiles
## for room in rooms:
##     for x in range(room.position.x, room.end.x):
##         for y in range(room.position.y, room.end.y):
##             tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)
