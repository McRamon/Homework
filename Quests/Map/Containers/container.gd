extends Node2D
class_name ItemContainer

@export var size: int = 10
var items: Array = [] # Each slot: { "item": Item, "amount": int }

const WORLD_ITEM_SCENE = preload("res://Quests/Map/World Objects/World Item/item_world.tscn")
var current_scene: Node = null

signal items_changed

func _ready():
	items.clear()
	for i in size:
		items.append(null)
	current_scene = get_tree().get_current_scene()
	_generate_loot()
		
func add_item(item: Item, amount: int = 1) -> int:
	var left = amount
	
	for i in range(size):
		if items[i]:
			print("Checking slot ", i, ": slot item =", items[i].item, ", new item =", item)
			print("Are they equal? ", items[i].item.name == item.name)
		if items[i] and items[i].item.name == item.name and item.stackable:
			var space = item.max_amount - items[i].amount
			var to_add = min(left, space)
			items[i].amount += to_add
			left -= to_add
			emit_signal("items_changed")
			print("***** ADDED, ", items[i].item, " - ", items[i].amount, " TO EXISTING SLOT")
			if left <= 0:
				return 0
	
	for i in range(size):
		if !items[i]:
			var to_add = min(left, item.max_amount if item.stackable else 1)
			items[i] = {"item": item, "amount": to_add}
			left -= to_add
			emit_signal("items_changed")
			if left<= 0:
				return 0
	print("Adding:", item.name, "x", amount, "Resource ID:", item.get_instance_id())
	return left
			
func remove_item(item: Item, amount: int = 1) -> int:
	var removed = 0
	for i in range(size):
		if items[i] and items[i].item == item:
			var take = min(amount - removed, items[i].amount)
			items[i].amount -= take
			removed += take
			if items[i].amount <= 0:
				items[i] = null
			if removed >= amount:
				break
	emit_signal("items_changed")
	return removed

# ✅ Checks if container has at least amount of item
func has_item(item: Item, amount: int = 1) -> bool:
	var count = 0
	for slot in items:
		if slot and slot.item == item:
			count += slot.amount
			if count >= amount:
				return true
	return false

# ✅ Gets first free slot index or -1 if full
func get_free_slot() -> int:
	for i in range(size):
		if !items[i]:
			return i
	return -1

# ✅ Debug print
func print_contents():
	print("Container Contents:")
	for i in range(size):
		if items[i]:
			print("Slot ", i, ": ", items[i].item.name, " x", items[i].amount)
		else:
			print("Slot ", i, ": Empty")
			
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for i in items:
			if i == null:
				return
			else:
				var dropped_scene = WORLD_ITEM_SCENE.duplicate().instantiate()
				dropped_scene.position = global_position
				dropped_scene.setup(i.item, i.amount)
				if current_scene:
					current_scene.add_child(dropped_scene)
				else:
					push_error("Current scene is null, cannot add dropped_scene!")
				
func _generate_loot():
	pass
		
