# bsp_tree_rooms.gd
# Binary Space Partitioning for structured floor plans
extends Node

class RoomNode:
	var x: int; var y: int; var w: int; var h: int
	var left: RoomNode; var right: RoomNode
	
	func split():
		# Logic to split vertically or horizontally 
		# until min_room_size is reached.
		pass
