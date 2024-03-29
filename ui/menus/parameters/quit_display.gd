class_name QuitDisplay extends Control

enum Type {
	RETURN,
	ABANDON
}

const menu_path: String = "res://ui/menus/main_menu/main_menu.tscn"

var type: Type

@export var label_quit: Label
@export var label_quit_content: Label
@export var back_button: MyButton
@export var continue_button: MyButton


func _ready() -> void:
	visible = false


func show_content(_type : Type) -> void:
	type = _type
	match type:
		Type.RETURN:
			label_quit.text = "BACK_TO_MENU"
			label_quit_content.text = "BACK_TO_MENU_CONTENT"
			continue_button.grab_focus()

		Type.ABANDON:
			label_quit.text = "ABANDON"
			label_quit_content.text = "ABANDON_CONTENT"
			back_button.grab_focus()

	visible = true


func hide_content() -> void:
	visible = false
	Parameters.previous_button.grab_focus()


func _on_back_button_button_down() -> void:
	hide_content()


func _on_continue_button_button_down() -> void:
	SceneTransition.change_scene(menu_path)
	match type:
		Type.RETURN:
			GameState.save_game()
		Type.ABANDON:
			GameState.erase_game()
