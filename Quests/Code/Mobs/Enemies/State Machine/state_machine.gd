extends Node
class_name AIStateMachine

const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")

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

func _has_targets_to_attack() -> bool:
	if owner.valid_attack_targets:
		return true
	else:
		return false
	

	#if _has_targets_to_attack():
		#_set_state(MobDefines.State.ATTACK)
	#if owner.patrol_points.size() > 0 and current_state != MobDefines.State.PATROL:
		#_set_state(MobDefines.State.PATROL)
		#print(self, " goes on a patrol")
		#
	#if owner.attack_target == null:
		#_set_state(MobDefines.State.IDLE)
		#return
	


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
#extends Resource
#class_name MobData
#
#const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")
#
#@export var mob_name: String = "Mob"
#@export var mob_description: String = "Standard Mob"
#@export var max_hp : int = 20
#@export var max_speed := 200.0  
#@export var starting_status_effects: Array[StatusEffect] = []
#
#@export_enum("PASSIVE", "HOSTILE", "AGRESSIVE")
#var mob_type: int = MobDefines.MobType.PASSIVE
#var current_state: int = MobDefines.State.IDLE
#var current_target: Node2D
#var myself: CharacterBody2D
#var timer_timing := false
#
#@export var attacks: Array
#var retreat_target_position:= Vector2.ZERO
#
#func on_attacked():
	#if mob_type == MobDefines.MobType.PASSIVE:
		#current_state = MobDefines.State.RETREAT
		#return
	#else:
		#current_state = MobDefines.State.ATTACK
		#start_combat()
		#
		#
#func start_combat():
	#pass
	#
#func on_idle():
	#if myself == null:
		#return
	#var navigator := myself.get_node("mob_navigator")
	#if !navigator.is_navigation_finished() or timer_timing:
		#return
	#var map_rid = navigator.get_navigation_map()
	#var radius = 50.0
	#var found := false
	#var tries = 0
	#
	#while not found and tries < 10:
		#var random_offset = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(10, radius)
		#var candidate_position = myself.global_position + random_offset
		#var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
		#
		#if candidate_position.distance_to(closest_point) < 10.0:
			#navigator.target_position = closest_point
			#found = true
			#timer_timing = true
			#myself.get_tree().create_timer(randf_range(5.0, 15.0)).timeout.connect(func(): timer_timing = false)
			#print(myself, " selected a point to move to, it is ", myself.global_position.distance_to(closest_point), "pixels away")
		#else:
			#tries += 1
	#
	#
#func on_patrol():
	#if myself == null:
		#return
	#if myself.patrol_points.size() == 0 or myself.patrol_points.is_empty():
		#print(" Mob ", myself, " has no patrol points, going IDLE")
		#return
		#
	#var navigator = myself.get_node("mob_navigator")
	#if not navigator.is_navigation_finished():
		#return
		#
	#if not myself.has_meta("patrol_points"):
		#myself.set_meta("patrol_index", 0)
	#var patrol_index = myself.get_meta("patrol_index")
	#
	## Clamp index to the valid range
	#if patrol_index >= myself.patrol_points.size():
		#patrol_index = 0
		#
	#var target_pos: Vector2 = myself.patrol_points[patrol_index]
	#navigator.target_position = target_pos
	#print(myself, " patrolling to ", target_pos)
	#patrol_index = (patrol_index + 1) % myself.patrol_points.size()
	#myself.set_meta("patrol_index", patrol_index)
	#
		#
#func on_retreat():
	#if current_target == null or myself == null:
		#myself.current_state = MobDefines.State.IDLE
		#return
		#
	#var dir_to_target = current_target.global_position.direction_to(myself.global_position)
	#
	#var found := false
	#var tries := 0
	#var navigator := myself.get_node("mob_navigator")
	#var map_rid = navigator.get_navigation_map()
	#
	#while not found and tries < 10:
		#var random_angle = randf_range(0.0, TAU)
		#var escape_direction = Vector2.RIGHT.rotated(random_angle).normalized()
		#var distance = randf_range(myself.chase_range, myself.chase_range + 200)
		#var candidate_position = myself.global_position + escape_direction * distance
		#
		#var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
		#
		#if candidate_position.distance_to(closest_point) < 400:
			#navigator.target_position = closest_point
			#retreat_target_position = closest_point
			#found = true
			#print("MOB ", myself, " is escaping to: ", retreat_target_position)
		#else:
			#tries += 1
			#
	#if not found:
		#print(" MOB ", myself, " tried to escape, but could not")
	##
	##return escape_direction
#
#
#func on_attack():
	#pass
	#
		 
