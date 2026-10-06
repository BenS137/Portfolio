extends Node


## general script for wrapping the world 
## we use it for the player so we can walk on one side out and appear again on the other side
## inspo source: Youtube Coding Kook

@onready # load viewport size for the wrap effect
var viewport_size := get_viewport().get_visible_rect().size

@onready # load positions of future duplicates
var duplicate_positions := [
	Vector2(viewport_size.x, 0), # right
	Vector2(-viewport_size.x, 0) # left
	]

func dup_for_wrap(node_to_dup: Node2D, parent: Node2D) -> void:
	# duplicates the node
	for dup_pos : Vector2 in duplicate_positions:
		var dup_node := node_to_dup.duplicate()
		
		dup_node.position = node_to_dup.position + dup_pos 
		
		parent.add_child(dup_node)
