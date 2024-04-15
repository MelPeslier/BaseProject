class_name MyCameraSpot
extends MyCamera

signal player_entered(_player: Player)
signal player_exited(_player: Player)

@export var player_detector: Area2D
@export var in_audio_stream: AudioStreamPlayer
@export var in_transition: float = 1.0
@export var out_transition: float = 1.0
@export var _trans := Tween.TRANS_EXPO
@export var _ease := Tween.EASE_OUT
@export var focus_on_enter_zone := true
@export var unfocus_on_exit_zone := true
@export var unfocus_timer: Timer
var player: Player = null

func _init() -> void:
	enabled = false

func _ready() -> void:
	super()
	player_detector.body_entered.connect( _on_player_detector_body_entered )
	player_detector.body_exited.connect( _on_player_detector_body_exited )

	if unfocus_timer:
		unfocus_timer.timeout.connect( _on_unfocus_timer_timeout )


func _on_player_detector_body_entered(body: Node2D) -> void:
	if not body is Player: return
	player = body
	if focus_on_enter_zone:
		CameraTransition.transition_camera2D(player.camera ,self, in_transition, _trans, _ease)
		if in_audio_stream:
			in_audio_stream.play()
	player_entered.emit(player)


func _on_player_detector_body_exited(body: Node2D) -> void:
	if not body is Player: return
	player_exited.emit(player)
	if unfocus_on_exit_zone:
		if unfocus_timer:
			unfocus_timer.start()
		else:
			_on_unfocus_timer_timeout()


func _on_unfocus_timer_timeout() -> void:
	CameraTransition.transition_camera2D(self, player.camera, out_transition, _trans, _ease)
	player = null


