extends Node
class_name ControlComponent

@export var attack_main: Ability
@export var attack_secondary: Ability
@export var ability: Ability
@export var movement_component: Node

func _ready():
	set_physics_process(true)
	
	
func _physics_process(delta: float) -> void:
	if attack_main and "update" in attack_main:
		attack_main.update(delta)
	if attack_secondary and "update" in attack_secondary:
		attack_secondary.update(delta)
	if ability and ability.has_method("update"):
		ability.update(delta)

func get_movement_input() -> Vector2:
	return Vector2.ZERO
	
func use_attack_main(mob, vector):
	if attack_main:
		attack_main.activate(mob, vector)
	
func use_attack_secondary(mob, vector):
	if attack_secondary:
		attack_secondary.activate(mob, vector)
	
func use_ability(mob, vector):
	if ability:
		ability.activate(mob, vector)
	else:
		push_error(" NULL ability ")
