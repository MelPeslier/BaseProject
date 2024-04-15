@tool
class_name MyButton
extends Button

static var min_size := Vector2(200, 60)
static var buttons: Array[MyButton] = []

@export var unique := false
@export var apply: bool : set = _set_apply

@export_category("Audio")
@export var ui_focused := SoundList.Ui.FOCUSSED
@export var ui_pressed := SoundList.Ui.PRESSED


func _init() -> void:
	theme_type_variation = "MyButton"
	if not unique:
		buttons.append(self)
		custom_minimum_size = min_size


func _ready() -> void:
	mouse_entered.connect( _on_mouse_entered )
	focus_entered.connect( _on_focus_entered )
	button_down.connect( _on_button_down )


static func _update_min_size() -> void:
	for button: MyButton in buttons:
		if not button.unique:
			button.custom_minimum_size = min_size


func _set_apply(_do: bool) -> void:
	if unique: return
	min_size = custom_minimum_size
	MyButton._update_min_size()


func _exit_tree() -> void:
	if buttons == null:
		return
	buttons.erase(self)


func _on_mouse_entered() -> void:
	grab_focus()

func _on_focus_entered() -> void:
	Sfx.play_ui( ui_focused )

func _on_button_down() -> void:
	Sfx.play_ui( ui_pressed )


