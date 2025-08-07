extends Mob
class_name MobEnemyBasic

const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")

@export var locator: Area2D
@export var patrol_points: Array[Vector2] = []
@export var chase_range: float = 400.0
@export var attack_range: float = 40.0
@export var mob_data: MobData

var current_state = MobDefines.State.IDLE
var patrol_index = 0
var valid_attack_targets: Array[CharacterBody2D]
var attack_target: CharacterBody2D
@export var enemy_groups: Array[StringName] = ["player_character"]


func _ready():
	super()
	if mob_data:
		health_component.max_health = mob_data.max_hp
		health_component.starting_status_effects.append(mob_data.starting_status_effects)
	_set_state(MobDefines.State.PATROL) # or IDLE
	# Optional: Register to some global enemy manager
	if get_parent().has_method("alive_enemies"):
		get_parent().alive_enemies.append(self)
	locator.body_entered.connect(_enemy_detected)

func _physics_process(delta):
	super(delta)
	match current_state:
		MobDefines.State.IDLE:
			_idle_state()
		MobDefines.State.PATROL:
			_patrol_state()
		MobDefines.State.RETREAT:
			_retreat_state()
		MobDefines.State.ATTACK:
			_attack_state()
	_enemy_escaped()

func on_death():
	if get_parent().alive_enemies:
		get_parent().alive_enemies.erase(self)
	super()

func _on_health_change(old_amount, new_amount):
	# Optional reaction (e.g. enter CHASE on hit)
	pass

func _set_state(new_state: MobDefines.State):
	current_state = new_state

func _idle_state():
	if mob_data:
		mob_data.on_idle()

func _patrol_state():
	if mob_data:
		mob_data.on_patrol()

	if _has_targets_to_attack():
		_set_state(MobDefines.State.ATTACK)

func _retreat_state():
	if mob_data:
		mob_data.on_retreat(self)

func _attack_state():
	if mob_data:
		mob_data.on_attack()

func _has_targets_to_attack() -> bool:
	if valid_attack_targets:
		return true
	else:
		return false

func _enemy_detected(body):
	for group in enemy_groups:
		if body.is_in_group(group) and body not in valid_attack_targets:
			valid_attack_targets.append(body)
	print(" MOB ", self, " IS FIGHTING: ", valid_attack_targets)
			
func _enemy_escaped():
	var roached_out = []
	for target in valid_attack_targets:
		var radius = locator.get_node("CollisionShape2D").shape.radius
		if global_position.distance_to(target.global_position) > chase_range:
			roached_out.append(target)
	for roach in roached_out:
		valid_attack_targets.erase(roach)
		print(roach, "ROACHED OUT! MOB ", self, " CURRENT TARGETS ARE: ", valid_attack_targets)
	if valid_attack_targets == []:
		_set_state(MobDefines.State.IDLE)
