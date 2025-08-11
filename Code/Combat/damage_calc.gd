extends Object
class_name DamageCalculator

const CombatDefines = preload("res://Code/Defines/combat_defines.gd")

func calculate_damage(damage: Dictionary, damage_resist : Dictionary):
	var total_damage: float = 0.0
	
	for dmg in damage.keys():
		var base_amount: float = damage[dmg]
		var resist: float = 0.0
		
		if damage_resist.has(dmg):
			resist = damage_resist[dmg]
			var calculated_damage = base_amount * max(0.0, 1.0 - resist)
			
			total_damage += calculated_damage
	return total_damage
