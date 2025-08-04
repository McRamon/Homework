extends Item
class_name ItemClothing

@export_enum("HAT", "SUIT", "GLOVES", "BOOTS")
var clothing_type: int = CombatConsts.ClothingType.HAT

@export var armor: int 
@export var resist: Dictionary = {
	CombatConsts.DamageTypes.FIRE: 0,
	CombatConsts.DamageTypes.COLD: 0,
	CombatConsts.DamageTypes.LIGHTNING: 0,
	CombatConsts.DamageTypes.POSION: 0,
	CombatConsts.DamageTypes.PHYSICAL: 0
}



 
