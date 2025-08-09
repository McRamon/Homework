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
	
func push(direction: Vector2, force: float):
	if force <= 0:
		return
	if _tween and _tween.is_valid():
		_tween.kill
		
	var push_velocity = direction.normalized() * force
	owner.movement_component.external_velocity = push_velocity
	_tween = create_tween()
	_tween.tween_property(owner.movement_component, "external_velocity", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		
func _check_collision(body):
		if body is TileMapLayer and _tween:
			_tween.kill()
			_tween = null
	
	
