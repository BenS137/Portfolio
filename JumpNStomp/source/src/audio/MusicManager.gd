extends Node
class_name MusicManager

var music_player: AudioStreamPlayer

var current_loop: AudioStream


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

	music_player.finished.connect(_on_music_finished)


# normale Musik mit Loop (z.B. Lobby)
func play_music(stream: AudioStream) -> void:
	current_loop = stream
	
	music_player.stream = stream
	music_player.play()


# Intro einmal spielen, danach Loop (z.B. Gameplay)
func play_intro_and_loop(intro: AudioStream, loop: AudioStream) -> void:
	current_loop = loop
	
	music_player.stream = intro
	music_player.play()


# wird aufgerufen wenn ein Track fertig ist
func _on_music_finished() -> void:
	if current_loop == null:
		return
	
	music_player.stream = current_loop
	music_player.play()


func stop_music() -> void:
	current_loop = null
	music_player.stop()
