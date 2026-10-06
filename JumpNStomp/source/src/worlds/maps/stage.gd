## ervery stage needs this in the parent node!!
## right now only makes pause possible


class_name Stage
extends Node2D
var pause_screen = preload("res://hand-in/source/src/menus/pause_menu.tscn")

func _input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_screen.instantiate())
		get_tree().paused = true

func _ready() -> void:
	# make player killable
	Global.is_in_lobby = false
