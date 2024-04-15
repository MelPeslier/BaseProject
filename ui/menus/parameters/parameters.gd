extends CanvasLayer


const v_syncs = {
	V_SYNC_DISABLED = DisplayServer.VSYNC_DISABLED,
	V_SYNC_ENABLED = DisplayServer.VSYNC_ENABLED,
	V_SYNC_ADAPTATIVE = DisplayServer.VSYNC_ADAPTIVE,
	V_SYNC_MAILBOX = DisplayServer.VSYNC_MAILBOX,
}

const screen_anchors = {
	LEFT_TOP = Vector2(2, 2),
	TOP = Vector2(1, 2),
	RIGHT_TOP = Vector2(0, 2),
	LEFT = Vector2(2, 1),
	CENTER = Vector2(1, 1),
	RIGHT = Vector2(0, 1),
	LEFT_BOT = Vector2(2, 0),
	BOT = Vector2(1, 0),
	RIGHT_BOT = Vector2(0, 0),
}

const display_modes = {
	FULL_SCREEN = [
		DisplayServer.WINDOW_MODE_FULLSCREEN,
	],
	WINDOWED = [
		DisplayServer.WINDOW_MODE_WINDOWED,
		[DisplayServer.WINDOW_FLAG_BORDERLESS, false],
	],
	WINDOWED_BORDERLESS = [
		DisplayServer.WINDOW_MODE_WINDOWED,
		[DisplayServer.WINDOW_FLAG_BORDERLESS, true],
	],
}

const resolutions: Array[Vector2i] = [
	Vector2i( 960, 540 ),
	Vector2i( 1920, 1080 ),
	Vector2i( 3840, 1080 ),
]

const framerate_limits: Array[int] = [
	30, 60, 75, 144
]

const PRIVATE_BUS_START: String = "_"
const RESET: String = "RESET"


@export var section_buttons: HBoxContainer
@export var bot_container: HBoxContainer

@export_category("Sections Contents")
@export var section_contents: PanelContainer
@export var quit_display: QuitDisplay

@export_group("Game")
@export var game_content: VBoxContainer
@export var languages_value: MyMenuButton

@export_group("Display")
@export var min_rect_size: Vector2i = Vector2i(150, 60)
@export var display_content: VBoxContainer
@export var display_screen_value: MyMenuButton
@export var display_mode_value: MyMenuButton
@export var resolution_value: MyMenuButton
@export var anchor_value: MyMenuButton
@export var v_sync_value: MyMenuButton
@export var framerate_limit_value: MyMenuButton
@export var show_framerate_value: CheckBox
@export var constrain_mouse_value: CheckBox

@export_group("Audio")
@export var audio_content: VBoxContainer

@export_group("Controls")
@export var controls_content: VBoxContainer
@export var game: MyButton
@export var display: MyButton
@export var audio: MyButton
@export var controls: MyButton
@export var back_to_menu: MyButton
@export var back: MyButton
@export var abandon: MyButton

var remap_buttons: Array[ControllerButton]

var user_display_prefs: UserDisplayPreferences
var user_audio_prefs: UserAudioPreferences
var user_controls_prefs: UserControlsPreferences
var user_game_prefs: UserGamePreferences

var first_item_path: Array[NodePath] = ["", "", "", ""]

var last_item_path: Array[NodePath] = ["", "", "", ""]

var previous_button: MyButton = game

var remap_container_scene: PackedScene = load("res://ui/menus/templates/button/remap_container.tscn")
@onready var my_button_scene: PackedScene = preload("res://ui/menus/templates/button/my_button.tscn")

var ui_elements: Array = []


func _ready() -> void:
	visible = false
	_init_audio_content()
	_init_display_content()
	_init_controls_content()
	_init_game_content()
	_connect_buttons()

func _unhandled_input(_event: InputEvent) -> void:
	if not ui_elements.is_empty():
		ui_elements.back().process_unhandled_input(_event)
		get_viewport().set_input_as_handled()
		return

	if Input.is_action_just_pressed("back"):
		if visible:
			resume_game()

		elif GameState.can_pause():
			pause_game()

		get_viewport().set_input_as_handled()



#region *** Pause ***
#TODO appear and disappear transitions
func pause_game() -> void:
	visible = true
	if GameState.in_game:
		back.text = "RESUME"
		get_tree().paused = true
		Sfx.play_ui(SoundList.Ui.MENU_OPEN)
		back_to_menu.visible = true
		abandon.visible = true
		show_mouse()
	else:
		back.text = "BACK"
		back_to_menu.visible = false
		abandon.visible = false
	_update_bot_buttons()
	previous_button.grab_focus()
	previous_button.button_down.emit()


func resume_game() -> void:
	visible = false
	if GameState.in_game:
		get_tree().paused = false
		hide_mouse()
		Sfx.play_ui(SoundList.Ui.MENU_CLOSED)

func hide_mouse() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)

func show_mouse() -> void:
	if user_display_prefs.constrain_mouse:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	else:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
#endregion


#region *** Display ***
func _init_display_content() -> void:
	# Take user display prefs
	user_display_prefs = UserDisplayPreferences.load_or_create()
	_update_user_display_prefs()

	resolution_value.get_popup().id_pressed.connect( _on_resolution_value_selected )
	_update_resolution_options()

	anchor_value.get_popup().id_pressed.connect( _on_anchor_value_selected )
	_update_screen_anchor_options()

	display_mode_value.get_popup().id_pressed.connect( _on_display_mode_value_selected )
	_update_display_mode_options()

	display_screen_value.get_popup().id_pressed.connect( _on_display_screen_value_selected )
	_update_display_screen_options()

	v_sync_value.get_popup().id_pressed.connect( _on_v_sync_value_selected )
	_update_v_sync_options()

	framerate_limit_value.get_popup().id_pressed.connect( _on_framerate_limit_value_selected )
	_update_framerate_limit_options()

	show_framerate_value.toggled.connect( _on_show_framerate_value_toggled )

	constrain_mouse_value.toggled.connect( _on_constrain_mouse_value_toggled )

	var display_reset_button: MyButton = my_button_scene.instantiate() as MyButton
	display_content.add_child(display_reset_button)
	display_reset_button.text = RESET
	display_reset_button.ui_pressed = SoundList.Ui.RESET
	display_reset_button.button_down.connect( _on_display_reset_button_down )
	last_item_path[1] = display_reset_button.get_path()

	var last_item = display
	var first := true
	for _item in display_content.get_children():
		if _item is HBoxContainer:
			_item.get_child(0).custom_minimum_size = Vector2(350, 30)
			var second = _item.get_child(1)
			if first:
				first_item_path[1] = second.get_path()
				first = false

			if not second is CheckBox:
				second.custom_minimum_size = Vector2(150, 30)

			if second is MenuButton:
				second.focus_mode = Control.FOCUS_ALL

			last_item.focus_neighbor_bottom = second.get_path()
			second.focus_neighbor_top = last_item.get_path()
			last_item = second

		elif _item is MyButton:
			last_item.focus_neighbor_bottom = _item.get_path()
			_item.focus_neighbor_top = last_item.get_path()
			_item.focus_neighbor_bottom = back.get_path()


#region Screen
func _update_display_screen_options() -> void:
	display_screen_value.get_popup().clear()
	var available_screens = DisplayServer.get_screen_count()
	for i: int in available_screens:
		var item: String = str( i + 1 )
		display_screen_value.get_popup().add_item(item)

func _on_display_screen_value_selected(_id: int) -> void:
	user_display_prefs.actual_screen = _id
	user_display_prefs.save()
	_set_screen()
	_set_display_mode()
	_set_resolution()
	_set_anchor()

func _set_screen() -> void:
	display_screen_value.text = str( DisplayServer.window_get_current_screen() + 1 )
	DisplayServer.window_set_current_screen( _get_screen() )
	_update_resolution_options()

func _get_screen() -> int:
	for i: int in DisplayServer.get_screen_count():
		if i == user_display_prefs.actual_screen:
			return user_display_prefs.actual_screen
	return DisplayServer.get_primary_screen()

func _on_display_screen_value_about_to_popup() -> void:
	_update_display_screen_options()
#endregion

#region Mode
func _update_display_mode_options() -> void:
	display_mode_value.get_popup().clear()
	for key: String in display_modes:
		display_mode_value.get_popup().add_item(key)

func _on_display_mode_value_selected(_id: int) -> void:
	var _key :String = display_modes.keys()[_id]
	user_display_prefs.display_mode = _key
	user_display_prefs.save()
	_set_display_mode()
	_set_resolution()
	_set_anchor()

func _set_display_mode() -> void:
	display_mode_value.text = user_display_prefs.display_mode
	for _option in display_modes.get(user_display_prefs.display_mode):
		if _option is DisplayServer.WindowMode:
			DisplayServer.window_set_mode( _option )
		elif _option is Array:
			if _option[0] is DisplayServer.WindowFlags and _option[1] is bool:
				DisplayServer.window_set_flag( _option[0], _option[1] )
#endregion

#region Resolution
func _update_resolution_options() -> void:
	resolution_value.get_popup().clear()
	var monitor_size : Vector2i = DisplayServer.screen_get_size(_get_screen())
	for res: Vector2i in resolutions:
		if res <= monitor_size:
			var title: String = str(res.x) + " x " + str(res.y)
			resolution_value.get_popup().add_item(title)

func _on_resolution_value_selected(_id: int) -> void:
	user_display_prefs.resolution = resolutions[_id]
	user_display_prefs.save()
	_set_resolution()
	_set_anchor()

func _set_resolution() -> void:
	resolution_value.text = str(user_display_prefs.resolution.x) + " x " + str(user_display_prefs.resolution.y)
	DisplayServer.window_set_size(user_display_prefs.resolution)

func _get_resolution() -> Vector2i:
	var monitor_size : Vector2i = DisplayServer.screen_get_size(_get_screen())
	if user_display_prefs.resolution <= monitor_size:
		return user_display_prefs.resolution
	return monitor_size
#endregion

#region Anchor
func _update_screen_anchor_options() -> void:
	anchor_value.get_popup().clear()
	for key: String in screen_anchors.keys():
		var x: int = screen_anchors[key].y
		if x == 0: x = 2
		elif x == 2: x = 0
		var y: int = screen_anchors[key].x
		if y == 0: y = 2
		elif y == 2: y = 0
		var path: String = "res://ui/menus/parameters/grid/grid_" + str( x ) + "_" + str( y ) + ".png"
		anchor_value.get_popup().add_icon_item( load( path ), "" )
		anchor_value.text = ""

func _on_anchor_value_selected(_id: int) -> void:
	var _key :String = screen_anchors.keys()[_id]
	user_display_prefs.screen_anchor = _key
	user_display_prefs.save()
	_set_anchor()

func _set_anchor() -> void:
	var x: int = screen_anchors[user_display_prefs.screen_anchor].y
	if x == 0: x = 2
	elif x == 2: x = 0
	var y: int = screen_anchors[user_display_prefs.screen_anchor].x
	if y == 0: y = 2
	elif y == 2: y = 0
	var path: String = "res://ui/menus/parameters/grid/grid_" + str( x ) + "_" + str( y ) + ".png"
	anchor_value.icon = load( path )
	var _size := _get_resolution()
	var _usable_rect := DisplayServer.screen_get_usable_rect(_get_screen())
	var _new_pos := _usable_rect.size - _size
	_new_pos.x = _new_pos.x - int( _new_pos.x * screen_anchors.get(user_display_prefs.screen_anchor).x / 2 ) + _usable_rect.position.x
	_new_pos.y = _new_pos.y - int( _new_pos.y * screen_anchors.get(user_display_prefs.screen_anchor).y / 2 ) + _usable_rect.position.y
	DisplayServer.window_set_position(_new_pos)

func _on_anchor_value_button_down() -> void:
	_update_screen_anchor_options()
#endregion

#region V-sync
func _update_v_sync_options() -> void:
	v_sync_value.get_popup().clear()
	for key: String in v_syncs:
		v_sync_value.get_popup().add_item(key)

func _on_v_sync_value_selected(_id: int) -> void:
	var _key: String = v_syncs.keys()[_id]
	user_display_prefs.v_sync = _key
	user_display_prefs.save()
	_set_v_sync()

func _set_v_sync() -> void:
	v_sync_value.text = user_display_prefs.v_sync
	DisplayServer.window_set_vsync_mode( v_syncs.get( user_display_prefs.v_sync ) )
#endregion

#region framerate limit
func _update_framerate_limit_options() -> void:
	framerate_limit_value.get_popup().clear()
	for key: int in framerate_limits:
		var title: String = str( key )
		framerate_limit_value.get_popup().add_item( title )

func _on_framerate_limit_value_selected(_id: int) -> void:
	user_display_prefs.framerate_limit = framerate_limits[_id]
	user_display_prefs.save()
	_set_framerate_limit()

func _set_framerate_limit() -> void:
	framerate_limit_value.text = str( user_display_prefs.framerate_limit )
	Engine.max_fps = user_display_prefs.framerate_limit
#endregion

#region show framerate
func _on_show_framerate_value_toggled(toggled: bool) -> void:
	user_display_prefs.show_framerate = toggled
	user_display_prefs.save()
	_set_show_framerate()

func _set_show_framerate() -> void:
	show_framerate_value.set_pressed_no_signal( user_display_prefs.show_framerate )
	DisplayUI.show_framerate( user_display_prefs.show_framerate )
#endregion

#region constrain mouse
func _on_constrain_mouse_value_toggled(toggled: bool) -> void:
	user_display_prefs.constrain_mouse = toggled
	user_display_prefs.save()
	_set_constrain_mouse()

func _set_constrain_mouse() -> void:
	constrain_mouse_value.button_pressed = user_display_prefs.constrain_mouse
	if user_display_prefs.constrain_mouse:
		DisplayServer.mouse_set_mode( DisplayServer.MOUSE_MODE_CONFINED )
	else:
		DisplayServer.mouse_set_mode( DisplayServer.MOUSE_MODE_VISIBLE )
#endregion


func _on_display_reset_button_down() -> void:
	user_display_prefs = UserDisplayPreferences.reset()
	_update_user_display_prefs()

func _update_user_display_prefs() -> void:
	_set_screen()
	_set_display_mode()
	_set_resolution()
	_set_anchor()
	_set_v_sync()
	_set_framerate_limit()
	_set_show_framerate()
	_set_constrain_mouse()
	user_display_prefs.save()
#endregion


#region *** Audio ***
func _init_audio_content() -> void:
	for item in audio_content.get_children():
		item.queue_free()

	var audio_params: PackedScene = load("res://ui/menus/templates/volume_sliders/my_audio_params.tscn")
	user_audio_prefs = UserAudioPreferences.load_or_create()

	var last_item = audio
	var first := true
	for _bus_index: int in AudioServer.bus_count:
		var _bus_name := AudioServer.get_bus_name(_bus_index)
		if not _bus_name.begins_with(PRIVATE_BUS_START):
			var _audio_params: MyAudioParams = audio_params.instantiate() as MyAudioParams
			_audio_params.bus_index = _bus_index
			AudioServer.set_bus_volume_db(
				_bus_index,
				linear_to_db( user_audio_prefs.volumes[_bus_index] )
			)
			audio_content.add_child(_audio_params)
			if first:
				first_item_path[2] = _audio_params.slider.get_path()
				first = false

			_audio_params.label.text = _bus_name.to_upper()

			last_item.focus_neighbor_bottom = _audio_params.slider.get_path()
			_audio_params.slider.focus_neighbor_top = last_item.get_path()
			last_item = _audio_params.slider

	var audio_reset_button = my_button_scene.instantiate()
	audio_content.add_child(audio_reset_button)
	audio_reset_button.text = RESET
	audio_reset_button.ui_pressed = SoundList.Ui.RESET
	audio_reset_button.button_down.connect( _on_audio_reset_button_down )
	last_item_path[2] = audio_reset_button.get_path()

	last_item.focus_neighbor_bottom = audio_reset_button.get_path()
	audio_reset_button.focus_neighbor_top = last_item.get_path()
	audio_reset_button.focus_neighbor_bottom = back.get_path()


func _on_audio_reset_button_down() -> void:
	user_audio_prefs = UserAudioPreferences.reset()
	for _bus_index in user_audio_prefs.volumes.size():
		AudioServer.set_bus_volume_db(
			_bus_index,
			linear_to_db( user_audio_prefs.volumes[_bus_index] )
		)
	for audio_param in audio_content.get_children():
		if audio_param is MyAudioParams:
			audio_param.update_params()
#endregion


#region *** Controls ***
func _init_controls_content() -> void:
	user_controls_prefs = UserControlsPreferences.load_or_create()
	var previous_item_top: Control = controls as Control
	# Create the appropriate control nodes and bind the next ui elements
	var first := true
	for i: int in range(user_controls_prefs.action_names.size()):
		var action_name: StringName = user_controls_prefs.action_names[i]
		var remap_container: RemapContainer = remap_container_scene.instantiate() as RemapContainer
		remap_container.action_name = action_name
		remap_container.user_controls_prefs = user_controls_prefs
		controls_content.add_child(remap_container)
		remap_container.remap_button.custom_minimum_size = Vector2(50, 50)
		remap_container.remap_label.custom_minimum_size = Vector2(150, 50)
		remap_buttons.append(remap_container.remap_button)

		if first:
			first_item_path[3] = remap_container.remap_button.get_path()
			first = false

		previous_item_top.focus_neighbor_bottom = remap_container.remap_button.get_path()
		if i == user_controls_prefs.action_names.size() - 1 :
			var controls_reset_button: MyButton = my_button_scene.instantiate() as MyButton
			controls_content.add_child(controls_reset_button)
			controls_reset_button.text = RESET
			controls_reset_button.ui_pressed = SoundList.Ui.RESET
			controls_reset_button.button_down.connect( _on_controls_reset_button_down )
			last_item_path[3] = controls_reset_button.get_path()

			remap_container.remap_button.focus_neighbor_bottom = controls_reset_button.get_path()
			controls_reset_button.focus_neighbor_top = remap_container.remap_button.get_path()
			controls_reset_button.focus_neighbor_bottom = back.get_path()
			back.focus_neighbor_top = remap_container.remap_button.get_path()
		else:
			remap_container.remap_button.focus_neighbor_top = previous_item_top.get_path()
		previous_item_top = remap_container.remap_button



func _on_controls_reset_button_down() -> void:
	user_controls_prefs = UserControlsPreferences.reset()
	for button: ControllerButton in remap_buttons:
		button.path = button.path
#endregion


#region *** Game ***
func _init_game_content() -> void:
	user_game_prefs = UserGamePreferences.load_or_create()
	_update_game_options()

	languages_value.get_popup().id_pressed.connect( _on_languages_value_selected )
	_update_languages_options()

	var first := true
	var last_item: Control = game
	for _item in game_content.get_children():
		if _item is HBoxContainer:
			var second = _item.get_child(1)
			if first:
				first_item_path[0] = second.get_path()
				first = false

			if second is MenuButton:
				second.focus_mode = Control.FOCUS_ALL

			second.custom_minimum_size = Vector2(120, 30)
			second.custom_minimum_size = Vector2(80, 30)
			last_item.focus_neighbor_bottom = second.get_path()
			second.focus_neighbor_top = last_item.get_path()
			last_item = second

	var game_reset_button: MyButton = my_button_scene.instantiate() as MyButton
	game_content.add_child(game_reset_button)
	game_reset_button.text = RESET
	game_reset_button.button_down.connect( _on_game_reset_button_down )
	game_reset_button.ui_pressed = SoundList.Ui.RESET
	game_reset_button.focus_neighbor_top = last_item.get_path()
	game_reset_button.focus_neighbor_bottom = back.get_path()

	last_item_path[0] = game_reset_button.get_path()



#region Language
func _update_languages_options() -> void:
	languages_value.get_popup().clear()
	for local: String in TranslationServer.get_loaded_locales():
		languages_value.get_popup().add_item( TranslationServer.get_language_name(local) )

func _on_languages_value_selected(_id: int) -> void:
	user_game_prefs.language = languages_value.get_popup().get_item_text( _id )
	user_game_prefs.save()
	_set_language()

func _set_language() -> void:
	var locals := TranslationServer.get_loaded_locales()
	if user_game_prefs.language.is_empty():
		var local := TranslationServer.get_locale().left(2)
		if local in locals:
			user_game_prefs.language = TranslationServer.get_language_name(local)
		else:
			user_game_prefs.language = locals[0]
	languages_value.text = user_game_prefs.language
	TranslationServer.set_locale( user_game_prefs.language.left(2).to_lower() )
#endregion

func _on_game_reset_button_down() -> void:
	user_game_prefs = UserGamePreferences.reset()
	_update_game_options()

func _update_game_options() -> void:
	_set_language()
#endregion


#region Parameter Buttons
func _connect_buttons() -> void:
	var last_item: MyButton = null
	for button: MyButton in section_buttons.get_children():
		#button.button_down.connect(Sfx.on_button_down)
		#button.mouse_entered.connect(Sfx.on_mouse_entered)
		if last_item:
			last_item.focus_neighbor_right = button.get_path()
			button.focus_neighbor_left = last_item.get_path()
		last_item = button

	last_item = null
	for button: MyButton in bot_container.get_children():
		break
		#button.button_down.connect(Sfx.on_button_down)
		#button.mouse_entered.connect(Sfx.on_mouse_entered)

	_update_bot_buttons()
	_on_game_button_down()

func _update_bot_buttons() -> void:
	var last_item: MyButton = null
	for button: MyButton in bot_container.get_children():
		if button.visible:
			if last_item:
				last_item.focus_neighbor_right = button.get_path()
				button.focus_neighbor_left = last_item.get_path()
			last_item = button


func update_focus_main_buttons(id: int) -> void:
	for button: MyButton in section_buttons.get_children():
		button.focus_neighbor_bottom = first_item_path[id]

	for button: MyButton in bot_container.get_children():
		button.focus_neighbor_top = last_item_path[id]


func _on_game_button_down() -> void:
	_disable_sections()
	game_content.visible = true
	update_focus_main_buttons(0)
	previous_button = game


func _on_display_button_down() -> void:
	_disable_sections()
	display_content.visible = true
	update_focus_main_buttons(1)
	previous_button = display


func _on_audio_button_down() -> void:
	_disable_sections()
	audio_content.visible = true
	update_focus_main_buttons(2)
	previous_button = audio


func _on_controls_button_down() -> void:
	_disable_sections()
	controls_content.visible = true
	update_focus_main_buttons(3)
	previous_button = controls


func _disable_sections() -> void:
	for section in section_contents.get_children():
		section.visible = false


func _on_back_to_menu_button_down() -> void:
	quit_display.show_content(QuitDisplay.Type.RETURN)


func _on_back_button_down() -> void:
	resume_game()


func _on_abandon_button_down() -> void:
	quit_display.show_content(QuitDisplay.Type.ABANDON)

#endregion





