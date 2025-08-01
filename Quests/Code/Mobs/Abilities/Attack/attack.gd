extends Action
class_name Attack

@export var damage:= 10
@export var weapon_effect: PackedScene
var effect_unpacked: AnimatedSprite2D
var user: CharacterBody2D

var active:= false
var hit_targets:= []


func activate(mob: CharacterBody2D, direction: Vector2):
	if active:
		return
	active = true
	hit_targets.clear()
	user = mob
	
	effect_unpacked = weapon_effect.instantiate() as AnimatedSprite2D
	effect_unpacked.rotation = direction.angle() + PI/2
	effect_unpacked.play("swing")
	mob.add_child(effect_unpacked)
	effect_unpacked.animation_finished.connect(_on_attack_finished)
	
	var area = effect_unpacked.get_node_or_null("attack_zone")
	if area:
		area.body_entered.connect(_on_body_entered)

func update(delta):
	pass
		
func _on_body_entered(body: Node2D):
	if body == user or body in hit_targets:
		return
	hit_targets.append(body)
	
	if body.get_node("HealthComponent").has_method("take_damage"):
		body.get_node("HealthComponent").take_damage(damage)
	
func _on_attack_finished():
	if effect_unpacked and is_instance_valid(effect_unpacked):
		effect_unpacked.queue_free()
	effect_unpacked = null
	active = false
