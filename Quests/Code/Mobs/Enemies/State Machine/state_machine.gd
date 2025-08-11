extends Node
class_name AIStateMachine

const MobDefines = preload("res://Quests/Code/Mobs/Defines/mob_defines.gd")

var current_state: int = MobDefines.State.IDLE
var current_target: Node2D
var speed_buffer := 0
var navigator

var valid_attack_targets: Array[CharacterBody2D]
var attack_target: CharacterBody2D

@export var idle_state : IdleState
@export var patrol_state : PatrolState
@export var retreat_state : RetreatState
@export var attack_state : AttackState
@export var timer: Timer


func _ready():
	speed_buffer = owner.movement_component.max_speed
	navigator = owner.navigator
	owner.locator.body_entered.connect(_enemy_detected)
	

func _physics_process(_delta):
	if valid_attack_targets == []:
		if owner.patrol_points:
			set_state(MobDefines.State.PATROL)
		else:
			set_state(MobDefines.State.IDLE)
	else:
		if owner.mob_type == MobDefines.MobType.PASSIVE:
			set_state(MobDefines.State.RETREAT)
		else:
			set_state(MobDefines.State.ATTACK)	
		
	match current_state:
		MobDefines.State.IDLE:
			owner.movement_component.max_speed = speed_buffer / 4.0
			idle_state.run(owner, navigator)
		MobDefines.State.PATROL:
			owner.movement_component.max_speed = speed_buffer / 2.0
			patrol_state.run(owner, navigator)
		MobDefines.State.RETREAT:
			owner.movement_component.max_speed = speed_buffer * 2
			retreat_state.run(owner, navigator)
		MobDefines.State.ATTACK:
			owner.movement_component.max_speed = speed_buffer
			attack_state.run(owner, navigator)
	_enemy_escaped()
	
func set_state(new_state: MobDefines.State):
	if current_state == new_state:
		return
	current_state = new_state
	match current_state:
		MobDefines.State.IDLE:
			idle_state.is_idle = false
		MobDefines.State.PATROL:
			patrol_state.is_patroling = false
		MobDefines.State.RETREAT:
			retreat_state.is_retreating = false
		MobDefines.State.ATTACK:
			attack_state.is_attacking = false

func _has_targets_to_attack() -> bool:
	if owner.valid_attack_targets:
		return true
	else:
		return false
	
func _enemy_detected(body):
	for group in owner.enemy_groups:
		if body.is_in_group(group) and body not in valid_attack_targets:
			valid_attack_targets.append(body)
			if attack_target == null:
				attack_target = body
	print(" MOB ", self, " IS FIGHTING: ", valid_attack_targets)
	print(" Current attack target: ", attack_target)

			
func _enemy_escaped():
	if valid_attack_targets:
		valid_attack_targets = valid_attack_targets.filter(
			func(target):
				return owner.global_position.distance_to(target.global_position) <= owner.chase_range
		)
		if attack_target not in valid_attack_targets:
			if valid_attack_targets:
				attack_target = valid_attack_targets.pick_random()
			else:
				attack_target = null
			print("TARGETS UPDATED! MOB ", self, " CURRENT TARGETS ARE: ", valid_attack_targets)
		
func start_timer(duration: float, target: Object, method: String) -> void:
	timer.stop()
	timer.disconnect("timeout", Callable(self, "_on_timer_timeout")) if timer.is_connected("timeout", Callable(self, "_on_timer_timeout")) else null
	timer.wait_time = duration
	timer.start()
	timer.connect("timeout", Callable(target, method), CONNECT_ONE_SHOT)
