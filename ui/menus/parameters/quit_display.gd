class_name QuitDisplay extends Control

enum Type {
	RETURN,
	ABANDON
}

const menu_path: String = "res://ui/menus/main_menu/main_menu.tscn"

var type: Type

@export var choice: ControlChoice
@export var screen_transition_packed : PackedScene

func _ready() -> void:
	visible = false
	choice.back_button.button_down.connect( _on_back_button_button_down )
	choice.continue_button.button_down.connect( _on_continue_button_button_down )


func process_unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("back"):
		hide_content()


func show_content(_type : Type) -> void:
	type = _type
	match type:
		Type.RETURN:
			choice.title_label.text = "BACK_TO_MENU"
			choice.content_label.text = "BACK_TO_MENU_CONTENT"
			choice.continue_button.grab_focus()

		Type.ABANDON:
			choice.title_label.text = "ABANDON"
			choice.content_label.text = "ABANDON_CONTENT"
			choice.back_button.grab_focus()

	visible = true
	Parameters.ui_elements.push_back(self)


func hide_content() -> void:
	Sfx.play_ui(SoundList.Ui.CANCEL)
	visible = false
	Parameters.ui_elements.pop_back()
	Parameters.previous_button.grab_focus()



func _on_back_button_button_down() -> void:
	hide_content()


func _on_continue_button_button_down() -> void:
	match type:
		Type.RETURN:
			GameState.save_game()
		Type.ABANDON:
			GameState.new_game()
	hide_content()
	Parameters.resume_game()
	#BaseLevel.level.process_mode = Node.PROCESS_MODE_DISABLED
	SceneTransition.change_scene(menu_path, screen_transition_packed)
