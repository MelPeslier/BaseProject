class_name UserControlsPreferences
extends Resource

const SAVE_PATH: String = "user://user_controls_prefs.tres"

var action_names: Array[String] = [
	"up",
	"down",
	"left",
	"right",
	"jump",
	"dash",
	"interact",
	"primary_attack",
	"secondary_attack",
]
var special_action_names: Array[String] = [
	"back"
]

@export var user_input_map: Dictionary = {}
var special_input_map: Dictionary = {}


func _init() -> void:
	_set_special_events()


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> UserControlsPreferences:
	var res: UserControlsPreferences = SafeResourceLoader.load(SAVE_PATH) as UserControlsPreferences
	if not res:
		res = UserControlsPreferences.reset()
	else:
		res._replace_user_input_map()
	return res

static func reset() -> UserControlsPreferences:
	var res: UserControlsPreferences = UserControlsPreferences.new()
	res._take_user_input_map()
	res.save()
	return res


func _take_user_input_map() -> void:
	InputMap.load_from_project_settings()
	for action_name: String in action_names:
		var input_events: Array[InputEvent] = InputMap.action_get_events(action_name)
		user_input_map[action_name] = input_events


func _replace_user_input_map() -> void:
	if user_input_map.is_empty() or not user_input_map.size() == action_names.size():
		_take_user_input_map()
		return
	for _action_name: String in user_input_map:
		var _input_events = user_input_map[_action_name]
		InputMap.action_erase_events(_action_name)
		for _input_event: InputEvent in _input_events:
			InputMap.action_add_event(_action_name, _input_event)


func change_and_replace(_action_name: String, _new_event: InputEvent) -> String:
	var other_action_name: String = ""
	var _input_events: Array[InputEvent] = user_input_map[_action_name]

	# _new_event n'a pas le droit dêtre un des évènements spécial
	for action_name: String in special_input_map:
		for _input: InputEvent in special_input_map[action_name]:
			if _input.get_class() == _new_event.get_class():
				match _new_event.get_class():
					"InputEventKey":
						var input: InputEventKey = _input as InputEventKey
						if input.keycode == _new_event.keycode:
							print("not allowed")
							return "not_allowed"
					"InputEventMouseButton":
						var input: InputEventMouseButton = _input as InputEventMouseButton
						if input.button_index == _new_event.button_index:
							print("not allowed")
							return "not_allowed"
					"InputEventJoypadButton":
						var input: InputEventJoypadButton = _input as InputEventJoypadButton
						if input.button_index == _new_event.button_index:
							print("not allowed")
							return "not_allowed"
					"InputEventJoypadMotion":
						var input: InputEventJoypadMotion = _input as InputEventJoypadMotion
						if input.axis == _new_event.axis:
							print("not allowed")
							return "not_allowed"
					_:
						print("type index shouldnt be something else")

	# On vérifie si l'élément existe dans une autre clée, auquel cas on assigne le nom de l'évènement à other actionn ame et on effectue l'échange
	for action_name: String in user_input_map:
		if not action_name == _action_name:
			for _input: InputEvent in user_input_map[action_name]:
				if _input.get_class() == _new_event.get_class():
					match _new_event.get_class():
						"InputEventKey":
							var input: InputEventKey = _input as InputEventKey
							if input.keycode == _new_event.keycode:
								other_action_name = action_name
						"InputEventMouseButton":
							var input: InputEventMouseButton = _input as InputEventMouseButton
							if input.button_index == _new_event.button_index:
								other_action_name = action_name
						"InputEventJoypadButton":
							var input: InputEventJoypadButton = _input as InputEventJoypadButton
							if input.button_index == _new_event.button_index:
								other_action_name = action_name
						"InputEventJoypadMotion":
							var input: InputEventJoypadMotion = _input as InputEventJoypadMotion
							if input.axis == _new_event.axis:
								other_action_name = action_name

	# FIXME choose between controller input and user input ???
	var type_index := -1
	match _new_event.get_class():
		"InputEventKey", "InputEventMouseButton":
			type_index = 0
		"InputEventJoypadButton", "InputEventJoypadMotion":
			type_index = 1

	var tmp: InputEvent = user_input_map[_action_name][type_index]
	user_input_map[_action_name][type_index] = _new_event

	InputMap.action_erase_events( _action_name )
	for event: InputEvent in user_input_map[_action_name]:
		InputMap.action_add_event( _action_name, event )

	if not other_action_name.is_empty():
		user_input_map[other_action_name][type_index] = tmp

		InputMap.action_erase_events( other_action_name )
		for event: InputEvent in user_input_map[other_action_name]:
			InputMap.action_add_event( other_action_name, event )
	save()
	return other_action_name


func _set_special_events() -> void:
	for special_action_name: String in special_action_names:
		var input_events: Array[InputEvent] = InputMap.action_get_events(special_action_name)
		special_input_map[special_action_name] = input_events




