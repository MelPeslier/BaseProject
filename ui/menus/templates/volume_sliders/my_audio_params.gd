class_name MyAudioParams
extends HBoxContainer

const MUTE_THRESHOLD: float = 0.03

var bus_index: int

@onready var label: Label = $Label
@onready var slider: HSlider = $Slider

@export_category("Audio")
@export var ui_focused := SoundList.Ui.FOCUSSED
@export var ui_slide := SoundList.Ui.SLIDE

var _old_val: float

func _ready() -> void:
	update_params()
	slider.value_changed.connect(_on_slider_value_changed)
	slider.mouse_entered.connect(_on_mouse_entered)
	slider.focus_entered.connect(_on_focus_entered)


func _on_slider_value_changed(_new_val: float) -> void:
	if _old_val == _new_val: return
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(_new_val)
	)
	if _new_val < MUTE_THRESHOLD :
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
	_old_val = _new_val
	Parameters.user_audio_prefs.volumes[bus_index] = _new_val
	Parameters.user_audio_prefs.save()


func _on_mouse_entered() -> void:
	slider.grab_focus()

func _on_focus_entered() -> void:
	Sfx.play_ui( ui_focused )


func update_params() -> void:
	slider.value = db_to_linear( AudioServer.get_bus_volume_db(bus_index) )
	_old_val = slider.value
	if slider.value < MUTE_THRESHOLD :
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
