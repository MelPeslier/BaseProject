extends CanvasLayer

@export var energy_component: EnergyComponent
@export var health_component: HealthComponent
@export var energy_ability: EnergyAttackHolder
@export var health_point_scene: PackedScene

@export var fill_time: float = 0.25
@export var drop_time: float = 0.4
@export var energy: float: set = _set_energy

@export var health_gui: HBoxContainer
@export var heart_beat: AudioStreamPlayer
@export var heart_beat_in: float = 1
@export var heart_beat_out: float = 2.5
var hp_tween: Tween
var is_last := false
var db_volume : float
@export var interval :float = 0.3

@export var fill: TextureRect
@export var spell_1: GUI_Spell
@export var spell_2: GUI_Spell
@export var energy_max_audio: AudioStreamPlayer
@export var energy_max_particles: GPUParticles2D
var is_energy_max := false

var energy_tween: Tween


func _ready() -> void:
	energy = 0
	visible = true
	db_volume = heart_beat.volume_db
	energy_component.energy_updated.connect( _on_energy_updated )
	health_component.health_changed.connect( _on_health_changed )
	energy_component.energy = energy_component.energy
	health_component.health = health_component.health
	is_last = is_equal_approx(health_component.health, 1.0)
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	for i: int in health_component.max_health:
		var hp: HealthPoint = health_point_scene.instantiate() as HealthPoint
		health_gui.add_child(hp)

	for i in health_gui.get_child_count():
		var hp: HealthPoint = health_gui.get_child(i) as HealthPoint
		timer.start(interval + MyRng.get_random(0, 0.25) )
		await timer.timeout
		if i + 1 > health_component.health:
			hp.lose_health()
		else:
			hp.gain_health()

	timer.queue_free()


func _on_health_changed(_health: float, _max_health: float) -> void:
	var _is_last = is_equal_approx(health_component.health, 1.0)
	if _is_last:
		if not is_last:
			last_hp(true)
	else:
		if is_last:
			last_hp(false)
	is_last = _is_last

	for i in health_gui.get_child_count():
		var hp: HealthPoint = health_gui.get_child(i) as HealthPoint
		if i + 1 > health_component.health:
			hp.lose_health()
		else:
			hp.gain_health()


func last_hp(_is_last: bool) -> void:
	var hp: HealthPoint = health_gui.get_child(0) as HealthPoint
	hp.last_hp(_is_last)

	if _is_last:
		heart_beat.volume_db = linear_to_db(Music.MIN_LINEAR)
		heart_beat.play()
		if hp_tween and hp_tween.is_running():
			hp_tween.kill()
		hp_tween = create_tween()
		Music._fade_in(hp_tween, heart_beat_in, heart_beat, db_volume)
		#Music.slow_down(heart_beat_in)
	else:
		if hp_tween and hp_tween.is_running():
			hp_tween.kill()
		hp_tween = create_tween()
		Music._fade_out(hp_tween, heart_beat_in, heart_beat)
		hp_tween.tween_callback( heart_beat.stop )
		#Music.back_to_normal(heart_beat_out)



func _on_energy_updated(_energy: float, _energy_max: float) -> void:
	if _energy >= energy_ability.energy_cost:
		spell_1.show_possible()
	else:
		spell_1.hide_possible()

	if _energy >= energy_ability.energy_cost * 2:
		spell_2.show_possible()
	else:
		spell_2.hide_possible()

	if _energy == energy_component.max_energy:
		if not is_energy_max:
			energy_max_audio.play()
			energy_max_particles.emitting = true
			is_energy_max = true
	elif is_energy_max:
		energy_max_particles.emitting = false
		is_energy_max = false

	var new_energy = clampf( remap(_energy, 0, _energy_max, 0, 1), 0, 1)
	if energy_tween and energy_tween.is_running():
		energy_tween.kill()

	var speed = fill_time if new_energy > energy else drop_time
	#speed *= new_energy - energy

	energy_tween = create_tween()
	energy_tween.tween_property(self, "energy", new_energy, speed)



func _set_energy(new_energy: float) -> void:
	energy = new_energy

	var mat: ShaderMaterial = fill.material as ShaderMaterial
	mat.set_shader_parameter("progress", energy)
