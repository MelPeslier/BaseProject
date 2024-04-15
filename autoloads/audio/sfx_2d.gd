extends Node


@export var metal_movement_sounds: Array[AudioStreamPlayer2D]
@export var metal_sword_hit_sounds: Array[AudioStreamPlayer2D]


func _play(_audio_stream_player: AudioStreamPlayer2D, _parent: Variant) -> void:
	var _asp := _audio_stream_player.duplicate() as AudioStreamPlayer2D
	_asp.finished.connect(_on_play_finished.bind(_asp))

	if _parent is Vector2:
		get_window().add_child(_asp)
		var pos: Vector2 = _parent as Vector2
		_asp.global_position = pos

	elif _parent is Node2D:
		_parent.add_child(_asp)
		_asp.global_position = _parent.global_position

	_asp.play()


func _on_play_finished(_asp: AudioStreamPlayer2D) -> void:
	_asp.queue_free()



func play_metal_movement(_metal_mouvement: SoundList.MetalMovement, _parent: Variant) -> void:
	var _audio_stream_player: AudioStreamPlayer2D = metal_movement_sounds[_metal_mouvement]
	if not _audio_stream_player: return
	_play(_audio_stream_player, _parent)


func play_metal_sword_hit(_metal_mouvement: SoundList.MetalSwordHit, _parent: Variant) -> void:
	var _audio_stream_player: AudioStreamPlayer2D = metal_sword_hit_sounds[_metal_mouvement]
	if not _audio_stream_player: return
	_play(_audio_stream_player, _parent)

