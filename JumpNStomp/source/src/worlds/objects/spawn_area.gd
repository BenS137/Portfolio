## Handles logic that belongs directly to a spawn Area2D:
## 1. Check whether this area is blocked by a living player.
## 2. Ignore the player that is currently respawning.
## 3. Optionally avoid another player, usually the killer.
## 4. Return a random spawn position inside this area.
##
## The actual respawn flow is handled by DeathComponent and SpawnManager.
## This script only contains logic that depends on the Area2D shape/position.
class_name SpawnArea
extends Area2D

# The avoid_player check is a bit taller than the SpawnArea shape.
# This makes it less likely to respawn directly above or below the avoided player.
const AVOID_PLAYER_EXTRA_HEIGHT := 80.0

@onready var spawn_area_shape := $SpawnAreaShape


func get_random_position() -> Vector2:
	# Returns a random spawn position inside this spawn area.
	var rectangle_shape := spawn_area_shape.shape as RectangleShape2D
	var half_size := rectangle_shape.size / 2.0

	var random_offset := Vector2(
		randf_range(-half_size.x, half_size.x),
		0
	)

	return global_position + random_offset


func is_blocked(
	ignore_player: Player = null, # Respawning player, should not block itself.
	avoid_player: Player = null # Player we prefer not to spawn near, usually the killer.
) -> bool:
	# Check players currently detected by the Area2D.
	for body in get_overlapping_bodies():
		var player := body as Player
		if player == null:
			continue

		if player == ignore_player:
			continue

		if player.death_component.dead:
			continue

		return true

	# Extra position-based check for avoid_player.
	# This can catch cases where the physics overlap list is not up to date.
	if avoid_player != null and not avoid_player.death_component.dead:
		if is_player_in_spawn_area(avoid_player):
			return true

	return false


func is_player_in_spawn_area(player: Player) -> bool:
	var rectangle_shape := spawn_area_shape.shape as RectangleShape2D
	var half_size := rectangle_shape.size / 2.0
	var local_player_position := to_local(player.global_position)

	return (
		abs(local_player_position.x) <= half_size.x
		and abs(local_player_position.y) <= half_size.y + AVOID_PLAYER_EXTRA_HEIGHT
	)
