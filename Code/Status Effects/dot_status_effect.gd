extends StatusEffect
class_name DOTStatusEffect

@export var is_heal: bool = false
@export var damage_per_tick: Dictionary = {
	CombatDefines.DamageType.POISON : 2
}
@export var heal_amount:= 5.0
@export var damage_type: int = CombatDefines.DamageType.MAGIC
@export var tick_interval: float = 1.0  # seconds between damage ticks

var _tick_timer: float = 0.0

func on_apply(target: Node):
	super(target)

func on_update(target: Node, delta: float) -> bool:
	if duration != 0:
		elapsed_time += delta
		
	_tick_timer += delta

	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		if !is_heal:
			if target.has_method("take_damage"):
				target.take_damage(damage_per_tick, damage_type)
				#print("Poison tick on ", target)
		else:
			if target.has_method("restore_health"):
				target.restore_health(heal_amount)
				#print("Heal tick on ", target)
	if duration == 0:
		return false
	return elapsed_time >= duration

func on_expire(target: Node):
	super(target)
	if !is_heal:
		print("Poison expired on ", target)
	else:
		print("Regeneration expired on ", target)
