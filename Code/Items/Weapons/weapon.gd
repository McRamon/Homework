extends Item
class_name ItemWeapon

@export var weapon_effect: PackedScene
@export var status_effects: Array[StatusEffect] = []

@export var damage: Dictionary = {
	CombatDefines.DamageType.PHYSICAL : 10,
	CombatDefines.DamageType.FIRE : 0,
	CombatDefines.DamageType.ICE : 0,
	CombatDefines.DamageType.LIGHTNING : 0,
	CombatDefines.DamageType.POISON : 0,
	CombatDefines.DamageType.MAGIC : 0
}
@export var attack_type := CombatDefines.AttackType.MELEE
@export var force:= 0
var caller_action : ActionControl = null
