extends BoxContainer
class_name BagUI

var player_bag: PlayerBag
var inventory_slots: Array[Control] = []

func _ready():
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player_character")
	var player = players[0]
	player_bag = player.player_inventory
	var slots = get_tree().get_nodes_in_group("inventory_slots")
	for slot in slots:
		inventory_slots.append(slot)
	if player_bag:
		player_bag.items_changed.connect(_on_inventory_changed)
		_update_ui()
		print("____________INVENTORY SLOTS INITIALIZED___________
		INVENTORY SLOTS: ", slots)

func _on_inventory_changed():
	_update_ui()
	print("========PLAYER BAG UPDATED")
	
func _update_ui():
	var items = player_bag.items
	
	for i in range(inventory_slots.size()):
		var slot = inventory_slots[i]
		var icon = slot.icon if slot.icon != null else null
		print(slot, " icon assigned to var icon")
		
		if i < items.size() and items[i] != null:
			var entry = items[i]
			icon.sprite_frames = entry.item.spritesheet
			icon.play(entry.item.get_animation("icon"))
			slot.set_amount(str(entry.amount))
			slot.visible = true
			print(slot, " icon is set to ", icon, ", ", slot, " amount is set to ", slot.get_amount())
		else:
			if icon:
				icon.sprite_frames = null
			slot.set_amount("")
			slot.visible = false
			print(" bag is empty")
			
