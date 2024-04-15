extends Node



@export var ui_sounds: Array[AudioStreamPlayer]
@export var action_sounds: Array[AudioStreamPlayer]

func _play(_audio_stream_player: AudioStreamPlayer) -> void:
	var _asp := _audio_stream_player.duplicate()
	_asp.finished.connect(_on_play_finished.bind(_asp))
	add_child(_asp)
	_asp.play()


func _on_play_finished(_asp: AudioStreamPlayer) -> void:
	_asp.queue_free()


#region UI

func play_ui(_ui: SoundList.Ui) -> void:
	if _ui == SoundList.Ui.NONE:
		return
	var _audio_stream_player: AudioStreamPlayer = ui_sounds[_ui]
	if not _audio_stream_player: return
	_play(_audio_stream_player)


func play_action(_action: SoundList.Action) -> void:
	if _action == SoundList.Ui.NONE:
		return
	var _audio_stream_player: AudioStreamPlayer = action_sounds[_action]
	if not _audio_stream_player: return
	_play(_audio_stream_player)



#
#func play_other(_audio_stream: AudioStream, _bus: String = other_bus) -> void:
	#_play(asp_other, _audio_stream, _bus)
#endregion

