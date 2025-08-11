extends BoxContainer
class_name InventorySlot

var icon:AnimatedSprite2D
var label:Label

func _ready():
	await get_tree().process_frame
	icon = $Control/inventory_slot_icon
	label = $Control/item_count
	print(self, " has icon and label assigned as follows: ", icon, label)

func _enter_tree():
	add_to_group("inventory_slots")
	
func set_amount(value: String):
	label.text = value
	
func get_amount() -> String:
	return label.text
