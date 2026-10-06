## one central place for all player characters
## if we add a new character, we add
## the name and the sheet path
##
## all character sprite sheets must have the same layout
## same frame size, same frame positions, same animation frames

class_name PlayerCharacterLibrary

# add new names here
const CHARACTER_NAMES := [
	"Default",
	"Bonsai",
	"Pirate",
	"Girly",
	"Gonzo",
	"Herobrine",
	"Stone Age"
]


# the sprite sheets must be in the same order as CHARACTER_NAMES.
const CHARACTER_SHEETS := [
	preload("res://hand-in/source/src/assets/player_sprites/NEW_player_default_p1_sheet.png"),
	preload("res://hand-in/source/src/assets/player_sprites/NEW_player_bonsai_sheet.png"),
	preload("res://hand-in/source/src/assets/player_sprites/pirate.png"),
	preload("res://hand-in/source/src/assets/player_sprites/girly.png"),
	preload("res://hand-in/source/src/assets/player_sprites/gonzo.png"),
	preload("res://hand-in/source/src/assets/player_sprites/herobrine.png"),
	preload("res://hand-in/source/src/assets/player_sprites/stone_age.png")
]


# makes sure that we cant go out of the number of selectable characters by wrapping it
static func normalize_character_index(character_index: int) -> int:
	if character_index >= CHARACTER_SHEETS.size():
		character_index = 0
		
	# returns index 
	return character_index


## returns the readable character name.
#static func get_character_name(character_index: int) -> String:
	#character_index = normalize_character_index(character_index)
#
	#return CHARACTER_NAMES[character_index]


# return the sprite sheet image for a character.
static func get_character_sheet(character_index: int) -> Texture2D:
	character_index = normalize_character_index(character_index)

	return CHARACTER_SHEETS[character_index]


# creates a new SpriteFrames resource for the chosen character.
#
#w why we need this:
# the player uses animatedSprite2D.
# animatedSprite2D does not use one simple texture.
# it uses SpriteFrames, which contain all animations.
#
# here we:
# 1. copy the existing animation setup
# 2. keeps all frame rectangles/cutouts
# 3. swaps only the big sprite sheet image
# 4. returns the new animation setup
#
# wayyy to much time i wasted on this...

static func create_sprite_frames(base_frames: SpriteFrames, character_index: int) -> SpriteFrames:
	# copy frames so we dont change the original player
	var new_frames := base_frames.duplicate(true) as SpriteFrames

	# get the sheet for the character we want
	var character_sheet := get_character_sheet(character_index)

	# go through every animation
	for animation_name in new_frames.get_animation_names():

		# go through every frame in the animation
		for frame_index in new_frames.get_frame_count(animation_name):

			# get the old frame
			var old_texture := new_frames.get_frame_texture(animation_name, frame_index) as AtlasTexture

			# if its not a sprite sheet cutout, skip it
			if old_texture == null:
				continue

			# copy the frame
			var new_texture := old_texture.duplicate() as AtlasTexture

			# keep the frame position but change the sprite sheet
			new_texture.atlas = character_sheet

			# put the changed frame back
			new_frames.set_frame(
				animation_name,
				frame_index,
				new_texture,
				new_frames.get_frame_duration(animation_name, frame_index)
			)

	return new_frames
