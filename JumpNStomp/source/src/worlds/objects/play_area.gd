## tracks what players are in level bounds
## kills player on leaving the area
## connects deaths to spawning and scoring


extends Area2D
class_name PlayArea

# players inside the area 2d
# updates on body entered
var players_in_area: Array[Player] = []

# prevents level startup killing the player before we even start playing
var game_started := false


# gets the sensor that does the check if and what player exited
@onready 
var area_sensor := $AreaSensor as CollisionShape2D

func _ready() -> void:
	# listen for players entering.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# listen for players leaving the play area.	
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


	# get players in area to listen to them
	var players := get_tree().get_nodes_in_group("player")

	# connects players
	for node in players:
		var player := node as Player
		_connect_player(player)

	# match starts and resets scoring 
	GameState.reset()
	
	# wait shortly before staring, giving the game time to load properly
	await get_tree().create_timer(0.5).timeout
	game_started = true
	
func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return

	if not players_in_area.has(player):
		players_in_area.append(player)


# checks player out of bounds
# sends it to death component to lt it handle the death
# also sends what player died and the reason
func _on_body_exited(body: Node2D) -> void:
	if not game_started:
		return

	if Global.game_over:
		return

	var player := body as Player
	if player == null:
		return

	players_in_area.erase(player)

	if player.death_component.dead:
		return

	# body_exited can also happen while collision is disabled during respawn.
	# Only count it as out of bounds if the player is below the play area.
	if not is_below_play_area(player):
		return

	print("OUT OF BOUNDS:", player.name)
	player.death_component.die("out_of_bounds")

func is_player_inside(player: Player) -> bool:
	return players_in_area.has(player)


func is_below_play_area(player: Player) -> bool:
	if area_sensor == null:
		return false

	var rectangle_shape := area_sensor.shape as RectangleShape2D
	if rectangle_shape == null:
		return false

	var local_player_position := area_sensor.to_local(player.global_position)
	var bottom_y := rectangle_shape.size.y / 2.0

	return local_player_position.y > bottom_y


func _on_player_died(
	body: Player,
	_reason: String = "",
	_killer: Player = null
	) -> void:
	if Global.game_over:
		return

	GameState.add_point_for_dead_player(body.name)

	var new_player := await SpawnManager.respawn_player(body, _killer)

	if new_player != null:
		_connect_player(new_player)


func _connect_player(player: Player) -> void:
	if player == null:
		return

	if not player.death_component.died.is_connected(_on_player_died):
		player.death_component.died.connect(_on_player_died)
