extends Node2D
class_name WeaponContainer

@export var weapon_data: ItemWeapon = null

var _player_in_range: Node = null


func _ready():
	await get_tree().process_frame
	var area = $detection_area
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	
func _process(delta):
	if _player_in_range and Input.is_action_pressed("interact"):
		_assign_weapon_to_player(_player_in_range)
		
func _on_body_entered(body):
	print(body, " near ", self)
	if body.has_node("ControlComponent"):
		_player_in_range = body
		
func _on_body_exited(body):
	print(body, " left ", self)
	if body == _player_in_range:
		_player_in_range = null
		
		
func _assign_weapon_to_player(player):
	var control = player.get_node_or_null("ControlComponent/action_use_item")
	if control:
		control.item = weapon_data
		
