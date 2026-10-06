extends RigidBody2D
class_name MapSelectionBox

var sound_machine: SoundMachine
# get the lobby variables
@onready
var lobby := get_parent().get_parent() as Lobby

func _ready() -> void:
		map_preview.texture = MapPathBus.maps[lobby.selected_map_index]["preview"]
		
	

# get the Sprite2d for map previews
@onready
var map_preview := $MapPreview as Sprite2D
	
# gets called by player colission component
# when get collider == PushableBox

# to make it only change once per stomp
var activated := false


func map_change_on_stomp(player: Player) -> void:
	# toggle on dont go further
	if activated:
		return
		
# ignores not stomps as a second check
	if player.state_machine.current_state is not StompStatePlayer:
		return
	sound_machine = player.sound_machine

	if sound_machine:
		sound_machine.play_sound("select")
		
		
	# if random map func in lobby didnt work 
	# in enter tree
	if lobby.selected_map_index == -1:
		lobby.selected_map_index = lobby.random_index(
		lobby.selected_map_index,
		MapPathBus.maps.size()
		)
			
			
		
		# to catch glitchy behavior we switch it of directily
	activated = true
	
	# change the map on stomp
	change_map()
	player.move_data.bounce_up()
		
		


func change_map() -> void:
		# wrap the ints so we cant stomp us out of the array
		# min being 0 and max the length of the array
		
	lobby.selected_map_index = wrapi(
		lobby.selected_map_index + 1, # + 1 because max is exclusive
		0,
		MapPathBus.maps.size()
		)

	map_preview.texture = MapPathBus.maps[lobby.selected_map_index]["preview"]
	Global.selected_map_scene = MapPathBus.maps[lobby.selected_map_index]["scene"]
	activated = false
