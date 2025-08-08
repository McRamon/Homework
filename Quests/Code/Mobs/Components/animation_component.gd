extends Node
class_name AnimationComponent

@export var mob: CharacterBody2D
@export var sprite: Sprite2D

var _tween: Tween
var push_it: bool = false

func _ready():
	if !mob:
		mob = self.get_parent()
	if !sprite:
		sprite = mob.get_node_or_null("mob_sprite")
		
func _physics_process(delta):
	if push_it && mob.get_slide_collision_count() > 0:
		_tween.stop()
		print("tween stopped")
		push_it = false

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
	
func push(direction: Vector2, force: int):
	if force <= 0 or push_it:
		return
	
	if _tween:
		_tween.kill()
	push_it = true
	var original_pos = mob.global_position
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(mob, "global_position", original_pos + (direction * 20 * force), 0.1 * force)
	_tween.tween_callback(func(): push_it = false)

		
func _check_collision(body):
		if body is TileMapLayer and _tween:
			_tween.kill()
			_tween = null
	
	
