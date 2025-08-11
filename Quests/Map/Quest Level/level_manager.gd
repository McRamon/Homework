extends Node2D
class_name LevelManager

var player_hp: int
var player_inventory: ItemContainer

var spawners: Array[Spawner] = []
var enemies: Array[Mob] = []
var containers: Array[ItemContainer] = []
var player: PlayerCharacter

func _ready():
	await get_tree().process_frame
	_begin_level_initializeialization()

func _begin_level_initializeialization():
	_initialize_map()
	_initialize_spawners()
	_initialize_mobs()
	_initialize_containers()
	_initialize_quest()
	_initialize_player()

func _initialize_map():
	pass
	
func _initialize_spawners():
	for child in get_children():
		if child.is_in_group("spawners"):
			spawners.append(child)
	if spawners.size() > 0:
		for s in spawners:
			s._initialize()
		print("Spawners succesfully initialized: ", spawners.size())
	else:
		push_warning("No spawners detected!")
	
func _initialize_mobs():
	pass
	
func _initialize_containers():
	pass
	
func _initialize_quest():
	pass
	
func _initialize_player():
	pass
