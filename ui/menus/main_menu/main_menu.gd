class_name MainMenu
extends Control

@export var credits_canvas_layer: CreditCanvasLayer
@export var buttons_container: VBoxContainer
@export var music_db_volume: float
@export_file("*.wav") var music_intro_path: String
@export_file("*.wav") var music_loop_path: String

var last_button : MyButton

func _ready() -> void:
	GameState.in_game = false
	Parameters.show_mouse()
	Music.db_volume = music_db_volume
	if not GameState.game_started:
		Music.change_sounds([music_intro_path], Music.CrossFade.NONE)
		GameState.game_started = true
	else:
		Music.change_sounds([music_intro_path], Music.CrossFade.OUT_IN)

	Music.audio_stream_players[0].finished.connect( _on_intro_finished )

	if GameState.saved_game.level_path == GameState.saved_game.start_level_path and GameState.saved_game.level_check_point_id == 0:
		buttons_container.get_child(0).visible = false

	for button: MyButton in buttons_container.get_children():
		if button.visible:
			last_button = button
			button.grab_focus()
			return


func _on_intro_finished() -> void:
	Music.change_sounds([music_loop_path], Music.CrossFade.NONE)


func _on_continue_button_down() -> void:
	SceneTransition.change_scene( GameState.saved_game.level_path )
	Parameters.hide_mouse()


func _on_new_game_button_down() -> void:
	GameState.new_game()
	SceneTransition.change_scene( GameState.saved_game.level_path )
	Parameters.hide_mouse()


func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_credits_button_down() -> void:
	last_button = %Parameters
	credits_canvas_layer.show_content()


func _on_parameters_button_down() -> void:
	last_button = %Credits
	Parameters.pause_game()

