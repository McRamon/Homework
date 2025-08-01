extends Attack
class_name AttackRanged

@export var distance:= 1500.0
@export var speed:= 300.0
@export var piercing: bool = false

var _direction: Vector2
var _travelled_distance: float = 0.0


func activate(mob: CharacterBody2D, direction: Vector2):
	if active:
		return
	active = true
	hit_targets.clear()
	user = mob
	_direction = direction.normalized()
	_travelled_distance = 0.0
	
	effect_unpacked = weapon_effect.instantiate() as AnimatedSprite2D
	effect_unpacked.rotation = direction.angle() + PI/2
	effect_unpacked.play("swing")
	mob.get_parent().add_child(effect_unpacked)
	effect_unpacked.global_position = mob.global_position
	
	
	var area = effect_unpacked.get_node_or_null("attack_zone")
	if area:
		area.body_entered.connect(_on_body_entered)

func update(delta):
	if not (effect_unpacked and is_instance_valid(effect_unpacked) and active):
		return
	var move_step = speed * delta
	effect_unpacked.global_position += _direction * move_step
	_travelled_distance += move_step
	if _travelled_distance >= distance:
		_on_attack_finished()
		
func _on_body_entered(body: Node2D):
	super(body)
	if !piercing:
		_on_attack_finished()
	
