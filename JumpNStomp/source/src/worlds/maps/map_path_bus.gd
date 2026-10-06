extends Node

## storage for map selection
## add new maps in the maps array 
## where each index is a dictionary

# belongs to itself 
# thats why we use static
# so we can access it more easily

static var maps : Array = [
		{
			"preview": preload("res://hand-in/source/src/assets/menu/map_previews/dont_fall_mittle.png"),
			"scene": "res://hand-in/source/src/worlds/maps/dont_fall_in_the_middle.tscn"
		},
		{
			"preview": preload("res://hand-in/source/src/assets/menu/map_previews/matrix_preview.png"),
			"scene": "res://hand-in/source/src/worlds/maps/matrix_kung_fu.tscn"
		},
		{
			"preview": preload("res://hand-in/source/src/assets/menu/map_previews/woods_preview.png"),
			"scene": "res://hand-in/source/src/worlds/maps/three platforms.tscn"
		},
		{
			"preview": preload("res://hand-in/source/src/assets/menu/map_previews/two_plattforms.png"),
			"scene": "res://hand-in/source/src/worlds/maps/two_platforms.tscn"
		}

	]
