extends StatusEffect
class_name ResistBuff

@export var damage_type: int = CombatDefines.DamageType.PHYSICAL
@export var amount: float = 0.1

func on_apply(target: HealthComponent):
	super(target)
	target.damage_resist[damage_type] += amount
	
func on_removal(target: HealthComponent):
	super(target)
	target.damage_resist[damage_type] -= amount
	
	
