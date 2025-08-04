extends Node2D
class_name LevelManager

var player_hp: int
var player_inventory: ItemContainer

var spawners: Array[Spawner] = []
var alive_enemies: Array[Mob] = []

	

func _ready():
	await get_tree().process_frame
	print(alive_enemies)

	

		
