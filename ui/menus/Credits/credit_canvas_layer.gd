class_name CreditCanvasLayer
extends CanvasLayer

@onready var back: MyButton = $Control/Back
@export var menu: MainMenu

func _ready() -> void:
	hide_content()


func process_unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("back"):
		_on_back_button_down()


func show_content() -> void:
	Parameters.ui_elements.push_back(self)
	visible = true
	set_process_unhandled_input(true)
	back.disabled = false


func hide_content() -> void:
	Parameters.ui_elements.pop_back()
	visible = false
	back.disabled = true
	set_process_unhandled_input(false)
	if menu.last_button:
		menu.last_button.grab_focus()


func _on_back_button_down() -> void:
	hide_content()
