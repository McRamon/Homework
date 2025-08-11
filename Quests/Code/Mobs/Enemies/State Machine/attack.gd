extends Node
class_name AttackState

const MobDefines = preload("res://Code/Defines/mob_defines.gd")
const CombatDefines = preload("res://Code/Defines/combat_defines.gd")
var is_attacking:= false
@export var attack_data: AiAttackData

func run(mob: CharacterBody2D, navigator: NavigationAgent2D):
	pass
	

func _attack_state():
	pass
	
