extends Node
class_name AnimationComponent

@export var mob: CharacterBody2D

func _ready():
	if !mob:
		mob = self.get_parent()

func animation_idle():
	pass
	
func animation_attack_melee():
	pass
	
func animation_jump():
	pass
	
	
