extends Mob
class_name MobEnemyBasic



@export var chase_range: float = 400.0
@export var attack_range: float = 40.0

#PASSIVE - убегает при столкновении
#HOSTILE - не нападает но отвечат на атаки
#AGRESSIVE - атакует при обнаружении
@export_enum("PASSIVE", "HOSTILE", "AGRESSIVE")
var mob_type: int = MobDefines.MobType.PASSIVE

@export var enemy_groups: Array[StringName] = ["player_character"]
@export var navigator: NavigationAgent2D
var patrol_points: Array[Vector2] = []
@export var locator: Area2D

func _ready():
	super()
	if get_parent().has_method("alive_enemies"):
		get_parent().alive_enemies.append(self)

func _physics_process(delta):
	super(delta)

func on_death():
	if get_parent().enemies:
		get_parent().enemies.erase(self)
	super()

func _on_health_change(old_amount, new_amount):
	pass
