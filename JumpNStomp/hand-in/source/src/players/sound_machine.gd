## here we handle everything sound 
## make here the sound so you can easily call the right sound for the given state
## call the sound in the func enter() after super()

extends Node
class_name SoundMachine


var sounds = {
	"jump": [
		preload("res://hand-in/source/src/audio/jumps/jump_1.wav"),
		preload("res://hand-in/source/src/audio/jumps/jump_2.wav")
	],

	"hit": [
		preload("res://hand-in/source/src/audio/hits/hit_box_1.wav"),
		preload("res://hand-in/source/src/audio/hits/hit_box_2.wav"),
		preload("res://hand-in/source/src/audio/hits/hit_box_3.wav")
	],

	"explosion_big_box": [
		preload("res://hand-in/source/src/audio/explosion_big_box/explosion_big_box.wav")
	],
	
	"explosion_player": [
		preload("res://hand-in/source/src/audio/explosion_player/explosion_player.wav")
	],
	
	"explosion_box": [
		preload("res://hand-in/source/src/audio/explosion/explosion_box.wav")
	],

	"select": [
		preload("res://hand-in/source/src/audio/select/select_world.wav")
	],
	
	"click": [
		preload("res://hand-in/source/src/audio/click/click.wav")
	],

	"countdown": [
		preload("res://hand-in/source/src/audio/countdown/countdown.wav")
	],

	"glide": [
		preload("res://hand-in/source/src/audio/glide/glide.wav")
	],

	"stomp": [
		preload("res://hand-in/source/src/audio/stomp/stomp.wav")
	],
	
	"footstep": [
		preload("res://hand-in/source/src/audio/footsteps/step_1.wav"),
		preload("res://hand-in/source/src/audio/footsteps/step_2.wav"),
		preload("res://hand-in/source/src/audio/footsteps/step_3.wav"),
		preload("res://hand-in/source/src/audio/footsteps/step_4.wav"),
		preload("res://hand-in/source/src/audio/footsteps/step_5.wav")
],
	"invisible_effect": [
		preload("res://hand-in/source/src/audio/invisible_effect/invisible_effect.wav")
]
}



var audio_player: AudioStreamPlayer


func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = "SFX"


func play_sound(sound_name: String):
	if sounds.has(sound_name):
		audio_player.stream = sounds[sound_name].pick_random()

		if sound_name == "footstep":
			audio_player.volume_db = -5
		else:
			audio_player.volume_db = 0

		audio_player.play()
