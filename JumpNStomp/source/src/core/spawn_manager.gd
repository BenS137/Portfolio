## handles player spawning and respawning.
## it asks spawn areas for free positions and creates new player instances.

extends Node

const PLAYER_SCENE := preload("res://hand-in/source/src/players/player.tscn")

# the spawn manager handles everything thats related with spawning the player. 
# it gets every spawn area in an array, and checks if it is blocked by another player
# if the spawn area is blocked wich is handld in the spawn_area.gd script 
# the player does not spawn after death in said area.

var free_spawn_areas: Array[SpawnArea] = []


func determine_free_spawn_areas(
	ignore_player: Player = null, # ignore killed player, 
	avoid_player: Player = null #avoid the other player (most likely the killer)
	) -> Array[SpawnArea]: 
		
	free_spawn_areas.clear()

	var spawn_areas := get_tree().get_nodes_in_group("spawn_area")

	for spawn in spawn_areas:
		var spawn_area := spawn as SpawnArea

		if spawn_area == null:
			continue

		if not spawn_area.is_blocked(ignore_player, avoid_player):
			free_spawn_areas.append(spawn_area)

	return free_spawn_areas

# ignore killed plyer, avoid the other player
# gets a random spawn are from the free spawn areas
# null makes it optioonal to not crash the game if no player is in  tree
func get_random_free_spawn_area(
	ignore_player: Player = null, 
	avoid_player: Player = null
	) -> SpawnArea:

	var free_areas := determine_free_spawn_areas(ignore_player, avoid_player)

	if not free_areas.is_empty():
		return free_areas.pick_random()

	var spawn_areas := get_tree().get_nodes_in_group("spawn_area")
	if spawn_areas.is_empty():
		return null

	return spawn_areas.pick_random() as SpawnArea

# respawn dead player, while avoiding alive player
func respawn_player(
	player: Player,
	avoid_player: Player = null
	) -> Player:

	# eemember the old parent before deleting dead player
	var parent := player.get_parent()

	# remember if player one or two
	var player_number := 1
	if player.player_number == 2 or player.name.ends_with("2"):
		player_number = 2

	# wait until the death animation has finished before removing the player
	await player.animation_data.play_death_and_wait()

	# remove the old dead player from the scene
	player.queue_free()

	# wait before spawning the player again
	await get_tree().create_timer(GameStats.respawn_delay).timeout

	# do not respawn after the game has ended
	if Global.game_over:
		return null

	# find a spawn area, preferably not blocked and not near the other alive player
	var spawn_area := get_random_free_spawn_area(null, avoid_player)

	if spawn_area == null:
		return null

	# create a fresh player instance and give it the old player number/name.
	var new_player := PLAYER_SCENE.instantiate() as Player
	var control_number := str(player_number)

	new_player.player_number = player_number
	new_player.name = "Player" + control_number

	# add the new player to the level 
	# place him at the chosen spawn position
	parent.add_child(new_player)
	
	
	new_player.global_position = spawn_area.get_random_position()

	return new_player
