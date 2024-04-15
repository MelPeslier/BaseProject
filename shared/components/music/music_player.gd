class_name MusicPlayer
extends Node

@export_category("Music")
@export_range(-60, 0) var db_music_volume: float = 0

@export_file("*.wav") var music_intro_path: String = ""

@export var music_loop_paths: Array[String] = []
var old_music_loop_paths : Array[String] = []
	#TODO le combat commence !



func play() -> void:
	Music.db_volume = db_music_volume
	Music.change_sounds([music_intro_path], Music.CrossFade.CROSS, Vector2(1, 0.75))
	Music.audio_stream_players[0].finished.connect( _on_intro_finished )
	Music.stream_changed.connect( _on_stream_changed )


func _on_intro_finished() -> void:
	if music_loop_paths.is_empty(): return
	Music.change_sounds(music_loop_paths, Music.CrossFade.NONE)


func _on_stream_changed() -> void:
	if Music.audio_stream_players[0].finished.is_connected( _on_intro_finished ):
		Music.audio_stream_players[0].finished.disconnect( _on_intro_finished )
