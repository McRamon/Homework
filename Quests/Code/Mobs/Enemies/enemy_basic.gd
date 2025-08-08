extends Mob
class_name MobEnemyBasic

const MobDefines = preload("res://Quests/Code/Mobs/mob_defines.gd")

@export var locator: Area2D
@export var patrol_points: Array[Vector2] = []
@export var chase_range: float = 400.0
@export var attack_range: float = 40.0
@export var mob_data: MobData

var current_state = MobDefines.State.IDLE
var patrol_index = 0
var valid_attack_targets: Array[CharacterBody2D]
var attack_target: CharacterBody2D
@export var enemy_groups: Array[StringName] = ["player_character"]
@export var navigator: NavigationAgent2D


func _ready():
	super()
	if mob_data:
		health_component.max_health = mob_data.max_hp
		for effect in mob_data.starting_status_effects:
			health_component.starting_status_effects.append(effect)
		mob_data.myself = self
		movement_component.max_speed = mob_data.max_speed
	_set_state(MobDefines.State.PATROL) # or IDLE
	# Optional: Register to some global enemy manager
	if get_parent().has_method("alive_enemies"):
		get_parent().alive_enemies.append(self)
	locator.body_entered.connect(_enemy_detected)

func _physics_process(delta):
	super(delta)

func on_death():
	if get_parent().alive_enemies:
		get_parent().alive_enemies.erase(self)
	super()

func _on_health_change(old_amount, new_amount):
	# Optional reaction (e.g. enter CHASE on hit)
	pass
