extends Node
class_name AnimationComponent

@export var mob: CharacterBody2D
@export var sprite: Sprite2D

var _tween: Tween

func _ready():
	if !mob:
		mob = self.get_parent()
	if !sprite:
		sprite = mob.get_node_or_null("mob_sprite")

func animation_idle():
	pass
	
func animation_walk():
	if not sprite:
		return
	pass
	
func animation_attack_melee():
	pass
	
func animation_jump():
	pass
	
	
