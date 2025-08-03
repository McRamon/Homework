extends Node
class_name ItemContainer

@export var size: int = 10
var items: Array = [] # Each slot: { "item": Item, "amount": int }

func _ready():
	for i in size:
		items.append(null)
		
func add_item(item: Item, amount: int = 1) -> int:
	var left = amount
	
	for i in range(size):
		if items[i] and items[i].item == item and item.stackable:
			var space = item.max_amount - items[i].amount
			var to_add = min(left, space)
			items[i].amount += to_add
			left -= to_add
			if left <= 0:
				return 0
	
	for i in range(size):
		if !items[i]:
			var to_add = min(left, item.max_amount if item.stackable else 1)
			items[i] = {"item": item, "amount": to_add}
			left -= to_add
			if left<= 0:
				return 0
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
	
