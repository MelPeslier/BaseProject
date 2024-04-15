class_name MoveData
extends Node

signal dir_changed(new_dir: float)

@export_category("test")
@export var test: bool: set =  _set_test

@export_category("walk")
@export_range(0, 2000, 1) var walk_distance: float = 1000
@export_range(0, 3) var walk_accel_time: float = 0.125
@export_range(0, 3) var walk_decel_time: float = 0.2
@export_range(0.01, 3) var walk_step_interval_time: float = 0.45
@export_range(0.01, 3) var run_step_interval_time: float = 0.3

@export_category("air")
@export_range(0.05, 100) var air_decel_time: float = 3

@export_category("jump")
@export_range(0, 5000, 1) var jump_height: float = 810
@export_range(0, 3) var jump_time_to_peak: float = 0.6
@export_range(0, 3) var jump_time_to_descent: float = 0.36
@export_range(0, 5000, 1) var max_fall_speed: float = 2200
@export_range(0, 1) var min_jump_coef: float = 0.35
@export var jump_peak_slow_gravity_threshold: float = 200
@export_range(0.2, 1) var jump_peak_slow_gravity_coef: float = 0.8

@export var jumps_number: int = 2
@export var next_jumps_coef: float = 0.25
@export var jump_buffer_time: float = 0.1
@export var jump_coyote_time: float = 0.1

@export_category("dash")
@export_range(0, 5000, 1) var dash_distance: float = 3000
@export_range(0.05, 1) var dash_time: float = 0.25

@export var dashes_number: int = 1
@export_range(0.05, 1) var dash_buffer_time: float = 0.15
@export_range(0.05, 3) var dash_interval_time: float = 1


# Walk
var walk_accel: float
var walk_decel: float
var step_interval_timer: float

# Air
var air_decel: float

# Jump
var initial_jump_velocity: float
var remaining_jumps: int = jumps_number
var jump_buffer_timer: float = 0
var jump_time: float = 0
var min_jump_time: float = 0
var jump_coyote_timer: float = 0

# Gravity
var gravity: float
var fall_gravity: float

# Direction
var old_dir: float = 1
var dir: float = 1: set = _set_dir

# Dash
var dash_buffer_timer: float = 0
var dash_timer: float = 0
var remaining_dashes: int = dashes_number
var dash_interval_timer: float = 0: set = _set_dash_interval_timer
var can_reload_dashes := false


var _can_move: bool = true


func _ready() -> void:
	_update_data()
	set_process(test)


func _process(_delta: float) -> void:
	_update_data()



func can_jump() -> bool:
	return remaining_jumps > 0 and can_move()

func alter_jumps(val: int) -> void:
	remaining_jumps = clampi(remaining_jumps + val, 0, jumps_number)

func get_jump_coef() -> float:
	return 1.0 - next_jumps_coef * ( jumps_number - remaining_jumps )


func can_dash() -> bool:
	return remaining_dashes > 0 and can_move

func alter_dashes(val: int) -> void:
	remaining_dashes = clampi(remaining_dashes + val, 0, dashes_number)

func reload_dashes() -> void:
	alter_dashes(dashes_number)


func can_move() -> bool:
	return _can_move

func disable_move() -> void:
	_can_move = false

func enable_move() -> void:
	_can_move = true



func _update_data() -> void:
	gravity = get_gravity(jump_height, jump_time_to_peak)
	fall_gravity = get_gravity(jump_height, jump_time_to_descent)
	initial_jump_velocity = get_velocity(jump_height, jump_time_to_peak)
	walk_decel = get_velocity(walk_distance, walk_decel_time)
	walk_accel = get_velocity(walk_distance, walk_accel_time)
	air_decel = get_velocity(walk_distance, air_decel_time)
	min_jump_time = jump_time_to_peak * min_jump_coef


#region Maths
func get_velocity(distance: float, time_to: float) -> float:
	return (2.0 * distance) / time_to

func get_gravity(distance: float, time_to: float) -> float:
	return ((2.0 * distance) / (time_to * time_to))
#endregion

#region Setters
func _set_test(new_val: bool) -> void:
	test = new_val
	set_process(test)

func _set_dir(new_dir: float) -> void:
	if new_dir == dir:
		return
	if new_dir == 0:
		dir = new_dir
		return
	old_dir = signf( new_dir )
	dir = old_dir
	dir_changed.emit(dir)

func _set_dash_interval_timer(new_val: float) -> void:
	dash_interval_timer = maxf(new_val, 0)
#endregion
