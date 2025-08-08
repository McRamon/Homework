extends Node
class_name AIStateMachine

const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")

var mob_type: int = MobDefines.MobType.PASSIVE
var current_state: int = MobDefines.State.IDLE
var current_target: Node2D
var myself: CharacterBody2D
var timer_timing := false
var speed_buffer := 0

@export var idle_state : IdleState
@export var patrol_state : PatrolState
@export var retreat_state : RetreatState
@export var attack_state : AttackState

func _ready():
	speed_buffer = owner.movement_component.max_speed

func _physics_process(delta):
	match current_state:
		MobDefines.State.IDLE:
			owner.movement_component.max_speed = speed_buffer / 4
			_idle_state()
		MobDefines.State.PATROL:
			owner.movement_component.max_speed = speed_buffer / 2
			_patrol_state()
		MobDefines.State.RETREAT:
			owner.movement_component.max_speed = speed_buffer * 2
			_retreat_state()
		MobDefines.State.ATTACK:
			owner.movement_component.max_speed = speed_buffer
			_attack_state()
	_enemy_escaped()
	
func _set_state(new_state: MobDefines.State):
	if current_state == new_state:
		return
	current_state = new_state


func _idle_state():
	if mob_data:
		mob_data.on_idle()

	if _has_targets_to_attack():
		_set_state(MobDefines.State.ATTACK)
	if patrol_points.size() > 0 and current_state != MobDefines.State.PATROL:
		_set_state(MobDefines.State.PATROL)
		print(self, " goes on a patrol")

func _patrol_state():
	if mob_data:
		mob_data.on_patrol()
	if patrol_points.is_empty():
		_set_state(MobDefines.State.IDLE)

	if _has_targets_to_attack():
		_set_state(MobDefines.State.ATTACK)

func _retreat_state():
	if mob_data == null:
		_set_state(MobDefines.State.IDLE)
		return
		
	if attack_target == null:
		_set_state(MobDefines.State.IDLE)
		return
		
	if navigator.is_navigation_finished():
		mob_data.on_retreat()
		
	
	

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
			if attack_target == null:
				attack_target = body
	print(" MOB ", self, " IS FIGHTING: ", valid_attack_targets)
	print(" Current attack target: ", attack_target)
	if mob_data.mob_type == MobDefines.MobType.PASSIVE:
		_set_state(MobDefines.State.RETREAT)
	else:
		_set_state(MobDefines.State.ATTACK)
			
func _enemy_escaped():
	var roached_out = []
	for target in valid_attack_targets:
		if global_position.distance_to(target.global_position) > chase_range:
			roached_out.append(target)
	for roach in roached_out:
		valid_attack_targets.erase(roach)
		print(roach, "ROACHED OUT! MOB ", self, " CURRENT TARGETS ARE: ", valid_attack_targets)
		if roach == attack_target:
			if valid_attack_targets.size() > 0:
				attack_target = valid_attack_targets.pick_random()
			else: attack_target = null
	if valid_attack_targets == []:
		_set_state(MobDefines.State.IDLE)
