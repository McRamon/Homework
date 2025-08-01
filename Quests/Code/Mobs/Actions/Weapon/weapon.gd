extends Action
class_name Weapon

@export var damage:= 10
@export var weapon_effect: PackedScene


func activate(mob: CharacterBody2D, direction: Vector2):
	if not super(mob, direction):
		return
	
	var effect = weapon_effect.instantiate() as AnimatedSprite2D
	effect.rotation = direction.angle() + PI / 2
	mob.add_child(effect)
	
	effect.position = Vector2.ZERO
	effect.user = mob
	effect.damage = damage

#func update(delta):
	#pass
		#
#func _on_body_entered(body: Node2D):
	#if body == user or body in hit_targets:
		#return
	#hit_targets.append(body)
	#
	#if body.get_node("HealthComponent").has_method("take_damage"):
		#body.get_node("HealthComponent").take_damage(damage)
	#
#func _on_attack_finished():
	#if effect_unpacked and is_instance_valid(effect_unpacked):
		#effect_unpacked.queue_free()
	#effect_unpacked = null
	#active = false
