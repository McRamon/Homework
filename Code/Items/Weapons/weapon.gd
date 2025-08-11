extends Item
class_name ItemWeapon

@export var weapon_effect: PackedScene
@export var status_effects: Array[StatusEffect] = []

@export var damage: Dictionary = {
	CombatDefines.DamageType.PHYSICAL : 10
}
@export var attack_type := CombatDefines.AttackType.MELEE
@export var force:= 0
var caller_action : Action = null

	
func use(user: CharacterBody2D, direction: Vector2, action: Action = null):
	caller_action = action
	var effect = weapon_effect.instantiate() as AnimatedSprite2D
	effect.rotation = direction.angle() + PI / 2
	effect.direction = direction
	user.add_child(effect)
	effect.weapon_data = self
	effect.position = Vector2.ZERO
	effect.user = user
	
	effect.mob_hit.connect(_on_mob_hit)
		
	return true
	
func _on_mob_hit(body):
	if body is CharacterBody2D:
		caller_action._on_mob_hit(body, damage, attack_type)
