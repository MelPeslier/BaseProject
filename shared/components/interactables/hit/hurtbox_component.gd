class_name HurtboxComponent
extends Area2D

signal hit_received(_attack_data: AttackData, _dir: Vector2)

@export var team := AttackData.Team.ENEMY
@export var parent: Node2D
@export_range(0, 10, 1) var energy_to_give: float
@onready var collision_shape: CollisionShape2D = get_child(0) as CollisionShape2D


var hitbox: HitboxComponent = null
var from_inside := false

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	area_shape_entered.connect(_on_area_shape_entered)
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if hitbox == null:
		set_physics_process(false)
		return
	var query := PhysicsRayQueryParameters2D.create(global_position, hitbox.global_position, collision_mask, [self])
	query.collide_with_areas = true
	query.collide_with_bodies = false
	from_inside = false
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		query.hit_from_inside = true
		from_inside = true
		result = get_world_2d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		print("hurtbox.gd : none from outside and inside l-39 :/ hit missed !")
		hitbox = null
		return

	if hitbox.energy_component and energy_to_give > 0 and hitbox.attack_data.can_gain_energy :
		hitbox.energy_component.gain(energy_to_give)

	var dir := hitbox.parent.global_position.direction_to(parent.global_position)

	#dir.x = 1 if dir.x > 0 else -1
	#dir.y = 1 if dir.y > 0 else -1
	var pos := hitbox.global_position

	if not from_inside:
		dir = result["normal"]
		pos = result["position"]

	hitbox.hit_gived_at.emit( pos )
	hit_received.emit(hitbox.attack_data, dir)
	hitbox = null


func _on_area_shape_entered(_area_rid: RID, _hitbox: HitboxComponent, _area_shape_index: int, _local_shape_index: int) -> void:
	if not _hitbox: return
	if _hitbox.parent == parent: return
	if _hitbox.attack_data.team == team: return
	hitbox = _hitbox
	set_physics_process(true)


func deactivate() -> void:
	collision_shape.set_deferred("disabled", true)


func activate(time: float = 0) -> void:
	if time > 0:
		var timer := Timer.new()
		add_child(timer)
		timer.start(time)
		await timer.timeout
		timer.queue_free()
	collision_shape.set_deferred("disabled", false)


