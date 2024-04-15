extends Node

signal stream_changed

enum CrossFade {
	NONE,
	CROSS,
	OUT_IN
}

enum Fade {
	OUT,
	IN
}

const MIN_LINEAR := 0.001

@export var bus_name: String = "Music"

#var current_index: int = 0
var db_volume : float = 0 : set = _set_db_volume

@onready var audio_stream_players : Array[AudioStreamPlayer] = [AudioStreamPlayer.new()]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child( audio_stream_players[0] )
	audio_stream_players[0].bus = bus_name



# ****************** #
#  PUBLIC functions  #
# ****************** #
func change_sounds(_audio_paths: Array[String], _cross_fade: CrossFade = CrossFade.CROSS, _fade_time := Vector2(1.5, 1.5) ) -> void:
	for i: int in _audio_paths.size():
		if audio_stream_players.size() <= i:
			var asp := AudioStreamPlayer.new()
			asp.bus = bus_name
			add_child(asp)
			audio_stream_players.push_back(asp)

		if i == 0:
			_change_sound( _audio_paths[i], audio_stream_players[i], _cross_fade, _fade_time )
			stream_changed.emit()
			continue
		if _cross_fade == CrossFade.NONE:
			audio_stream_players[i].volume_db = -60
			_change_stream( _audio_paths[i], audio_stream_players[i] )
		else:
			var tween: Tween = create_tween()
			_fade_out(tween, _fade_time.y, audio_stream_players[i])
			tween.tween_callback( _change_stream.bind( _audio_paths[i], audio_stream_players[i] ) )
			tween.tween_callback(_set_volume.bind( MIN_LINEAR, audio_stream_players[i]) )

		audio_stream_players[i].play(audio_stream_players[0].get_playback_position())

	while audio_stream_players.size() > _audio_paths.size():
		audio_stream_players[audio_stream_players.size()-1].queue_free()
		audio_stream_players.pop_back()



func fade_sounds(_fade: Fade, list_index: int = 0, _fade_time := Vector2(0.3, 0.3)) -> void:
	for i: int in audio_stream_players.size():
		match _fade:
			Fade.IN:
				if i <= list_index and audio_stream_players[i].volume_db <= -60:
					var tween: Tween = create_tween()
					_fade_in(tween, _fade_time.x, audio_stream_players[i], db_volume)

			Fade.OUT:
				if i >= list_index and audio_stream_players[i].volume_db >= db_volume:
					var tween: Tween = create_tween()
					_fade_out(tween, _fade_time.y, audio_stream_players[i])


# ******************* #
#  PRIVATE functions  #
# ******************* #


func _change_sound(_song_path: String, _asp: AudioStreamPlayer, _cross_fade: CrossFade, _fade_time: Vector2) -> void:
	match _cross_fade:
		CrossFade.NONE:
			_set_volume( db_to_linear(db_volume), _asp )
			_change_stream(_song_path, _asp)
			_asp.play()

		CrossFade.CROSS:
			var dummy_player := AudioStreamPlayer.new()
			dummy_player.bus = bus_name
			dummy_player.volume_db = db_volume
			dummy_player.stream = _asp.stream
			add_child( dummy_player )
			dummy_player.play(_asp.get_playback_position())
			_asp.stop()
			_change_stream(_song_path, _asp)
			_asp.volume_db = linear_to_db(MIN_LINEAR)
			_asp.play()
			var _tween: Tween = create_tween()
			_tween.set_parallel()
			_fade_in( _tween, _fade_time.x, _asp, db_volume )
			_fade_out( _tween, _fade_time.y, dummy_player )
			_tween.set_parallel(false)
			_tween.tween_callback( dummy_player.stop )
			_tween.tween_callback( dummy_player.queue_free )

		CrossFade.OUT_IN:
			var _tween: Tween = create_tween()
			_tween.set_parallel(false)
			_fade_out(_tween, _fade_time.y, _asp)
			_tween.tween_callback( _set_volume.bind( db_to_linear(db_volume), _asp ) )
			_tween.tween_callback( _change_stream.bind( _song_path, _asp ) )
			_tween.tween_callback( _asp.play )
			_fade_in(_tween, _fade_time.x, _asp, db_volume)


func _change_stream(_new_song_path: String, asp: AudioStreamPlayer) -> void:
	var audio_stream: AudioStream = load(_new_song_path)
	if audio_stream == null:
		print("can't load audio file")
		return
	asp.stream = audio_stream


func _fade_out(_tween: Tween, _speed: float, _asp: AudioStreamPlayer) -> void:
	_tween.tween_method(_set_volume.bind(_asp), db_to_linear(_asp.volume_db), MIN_LINEAR, _speed)


func _fade_in(_tween: Tween, _speed: float, _asp: AudioStreamPlayer, _db_volume) -> void:
	_tween.tween_method(_set_volume.bind(_asp), MIN_LINEAR, db_to_linear(_db_volume), _speed)


func _set_volume(_val: float, _asp: AudioStreamPlayer) -> void:
	_asp.volume_db = linear_to_db(_val)


func _set_db_volume(_linear_volume: float) -> void:
	db_volume = clampf(_linear_volume, -60, 0)
