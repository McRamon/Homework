extends Item
class_name ItemWeapon

@export var weapon_effect: PackedScene
@export var status_effects: Array[StatusEffect] = []

@export var damage: Dictionary = {
	CombatDefines.DamageType.PHYSICAL : 10
}
@export var force:= 0

	
func use(user: CharacterBody2D, direction: Vector2, action: Action = null):
	
	var effect = weapon_effect.instantiate() as AnimatedSprite2D
	effect.rotation = direction.angle() + PI / 2
	effect.direction = direction
	user.add_child(effect)
	effect.weapon_data = self
	effect.position = Vector2.ZERO
	effect.user = user
	
	if action:
		effect.mob_hit.connect(action._on_mob_hit)
		
	return true
