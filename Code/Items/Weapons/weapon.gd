extends Item
class_name ItemWeapon

@export var weapon_effect: PackedScene
@export var status_effects: Array[StatusEffect] = []

@export var damage:= 10
@export var force:= 0

	
func use(mob: CharacterBody2D, direction: Vector2):
	
	var effect = weapon_effect.instantiate() as AnimatedSprite2D
	effect.rotation = direction.angle() + PI / 2
	effect.direction = direction
	mob.add_child(effect)
	effect.weapon_data = self
	effect.position = Vector2.ZERO
	effect.user = mob
	effect.damage = damage
	effect.force = force
	return true
