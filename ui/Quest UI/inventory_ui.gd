extends HBoxContainer

var inventory_slots: Array

func _ready():
	var slots = get_tree().get_nodes_in_group("inventory_slots")
	for slot in slots:
		inventory_slots.append(slot)
