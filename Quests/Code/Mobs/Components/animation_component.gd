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
	
	if _tween and _tween.is_running():
		return
		
	_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.set_loops()
	_tween.set_parallel().tween_property(mob, "position y", mob.position.y + 2, 0.2)
	_tween.tween_property(mob, "rotation", mob.rotation + 10, 0.2)
	_tween.set_parallel().tween_property(mob, "position y", mob.position.y, 0.2)
	_tween.tween_property(mob, "rotation", mob.rotation, 0.2)
	
func animation_attack_melee():
	pass
	
func animation_jump():
	pass
	
	
