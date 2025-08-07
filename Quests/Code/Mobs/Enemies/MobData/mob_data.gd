extends ResourceManager
class_name MobData
const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")

@export var mob_name: String = "Mob"
@export var mob_description: String = "Standard Mob"
@export var max_hp : int = 20
@export var starting_status_effects: Array[StatusEffect] = []


@export var mob_type: int = MobDefines.MobType.PASSIVE
var current_state: int = MobDefines.State.IDLE

@export var attacks: Array

func on_attacked(attacker):
	if mob_type == MobDefines.MobType.PASSIVE:
		current_state = MobDefines.State.RETREAT
		return
	else:
		current_state = MobDefines.State.ATTACK
		start_combat(attacker)
		
		
func start_combat(attacker):
	pass
	
func on_idle():
	pass
	
func on_patrol():
	pass
	#if patrol_points.is_empty():
		#_set_state(MobDefines.State.IDLE)
#
	#if control_component.navigator.is_navigation_finished():
		#patrol_index = (patrol_index + 1) % patrol_points.size()
		#control_component.set_target(patrol_points[patrol_index])
		
func on_retreat(mob):
	pass

func on_attack():
	pass
	
		 
