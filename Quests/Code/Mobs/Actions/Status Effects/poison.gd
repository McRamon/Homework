extends StatusEffect
class_name PoisonStatusEffect

@export var tick_damage: int = 2
@export var tick_interval: float = 1.0  # seconds between damage ticks

var _tick_timer: float = 0.0

func _init():
	effect_name = "Poison"
	duration = 5.0  # default 5 seconds

func on_apply(target: Node):
	print("Poison applied to ", target.name)

func on_update(target: Node, delta: float) -> bool:
	elapsed_time += delta
	_tick_timer += delta

	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		if target.has_method("take_damage"):
			target.take_damage(tick_damage)
			print("Poison tick on ", target.name)

	return elapsed_time >= duration

func on_expire(target: Node):
	print("Poison expired on ", target.name)
