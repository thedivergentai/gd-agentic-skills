# rendering_server_direct.gd
# Bypassing the Node tree for massive item rendering
extends Node2D

# EXPERT NOTE: The RenderingServer allows you to draw 
# millions of items by avoiding the overhead of the Node 
# hierarchy. Each canvas item is just an RID in the server.

var items: Array[RID] = []

func _ready():
	var canvas = get_canvas_item()
	for i in range(1000):
		var item = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(item, canvas)
		RenderingServer.canvas_item_add_rect(item, Rect2(i, i, 10, 10), Color.RED)
		items.append(item)

func _exit_tree():
	for item in items:
		RenderingServer.free_rid(item)
