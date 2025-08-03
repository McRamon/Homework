extends Node
class_name ControlComponent

var attack_main: Action
var attack_secondary: Action
var ability: Node
var movement_component: Node

func _ready():
	await get_tree().process_frame
	attack_main = $action_use_item
	ability = $ability
	set_physics_process(true)
	print("player attack main = ", $attack_main)

func _physics_process(delta: float) ->void:
	pass

func get_movement_input() -> Vector2:
	return Vector2.ZERO
	
func use_attack_main(mob: CharacterBody2D, direction: Vector2):
	if attack_main:
		attack_main.activate(mob, direction)
	else:
		print("no attack main detected")
	
func use_attack_secondary(mob: CharacterBody2D, direction: Vector2):
	if attack_secondary:
		attack_secondary.activate(mob, direction)
	
func use_ability(mob, vector):
	if ability:
		ability.activate(mob, vector)
	else:
		push_error(" NULL ability ")
