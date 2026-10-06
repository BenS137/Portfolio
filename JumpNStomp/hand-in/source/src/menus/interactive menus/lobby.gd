## a lobby for both players to get a felling for the game and adjust settings before starting
##
## important note:
## the settings are saved on lcal variables and are given to Global when the game starts
##
## all settings can be are changeed by stomping the box

extends Node2D
class_name Lobby

# -1 is not chosen yet and makes it random, making a fast start possible
# by makin -1 indexes a random new index
# with the random_index function
var timer_enabled : bool = false
var timer_minutes : int = 0
var target_score : int = 10 
var selected_map_index : int = -1
var p1_character_index : int = -1
var p2_character_index : int = -1

# we only put lobby specific things in like making players unkillable in the ready
# because the variabbles dont translate on ready
# that is because the children readys git statusrun first
# so from buttom to top
# this leads to the character having a sprite already until we reach this ready
func _ready() -> void:
	music_manager.play_music(
		preload("res://hand-in/source/src/audio/MusicManager/lobby/main_theme.wav")
	)
	
	# makes player in lobby unkillable
	Global.is_in_lobby = true
	

# the scene tree builds from parent to children
# really important for assigning the values to global
# and making sure the sprite starts random
# 
func _enter_tree() -> void:
	
	# gets new random seed
	# so we get a truly random number from ranfmom integer
	randomize()

	# we get a random map if none was chosen
	var random_map_index := random_index(
		selected_map_index, 
		MapPathBus.maps.size()
		)
	# lobby starts with a random map selected
	selected_map_index = random_map_index
	

	# we also get a random character by using the same function
	var random_player_1_character_index := random_index(
		p1_character_index,
		PlayerCharacterLibrary.CHARACTER_SHEETS.size()
		)
	# and a random player 1
	p1_character_index = random_player_1_character_index
		
		
	# and for player 2...
	var random_player_2_character_index := random_index(
		p2_character_index,
		PlayerCharacterLibrary.CHARACTER_SHEETS.size()
		)
	# and random player 2
	p2_character_index = random_player_2_character_index
	
	# sets the Global map scene path to the selected map
	Global.selected_map_scene = MapPathBus.maps[selected_map_index]["scene"]
	
	# also the player sprites 
	
	# player 1
	Global.player1_character = p1_character_index
	
	# player 2
	Global.player2_character = p2_character_index	


# check if value is -1 
# if yes making the selection random 
# if not -1 dont change anything, because you selected something
func random_index(index: int, option_count: int) -> int:
	
	# catches everything smaller than -1
	if option_count <= 0:
		return -1

	# -1 means nothing selected -> so we get a random index
	if index == -1:
		return randi_range(0, option_count - 1)
	
	# check if we went too far
	if index >= option_count:
		return 0
	
	# when a map was selected (indexx not -1) just pass the value through
	return index
	
#func _unhandled_input(event: InputEvent) -> void:
#
	#if event.is_action_pressed("ui_cancel"):
		#exit_sound.play()
		#exit_label.text = "THANKS FOR PLAYING :D"
		#exit_label.visible = true
		#
		#
		#await get_tree().create_timer(2.0).timeout
		#get_tree().quit()

			
	
