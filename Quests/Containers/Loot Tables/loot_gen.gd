extends Resource
class_name LootGenerator

@export var loot_entries: Array[LootEntry] = []
@export var total_weight: int = 10

func generate_loot() -> Array:
	var result: Array = []
	var remaining_weight = total_weight

	var valid_entries = loot_entries.filter(func(e): return e.weight > 0)
	for e in valid_entries:
		print("  • ", e.item.name, 
		  "| Weight:", e.weight, 
		  "| Unit Weight:", e.unit_weight, 
		  "| Amount:", e.amount_min, "-", e.amount_max)
	if valid_entries.is_empty():
		return result

	while remaining_weight > 0 and not valid_entries.is_empty():
		var chosen_entry: LootEntry = _weighted_pick(valid_entries)
		if chosen_entry == null:
			break

		var weight_per_unit = chosen_entry.unit_weight
		if weight_per_unit > remaining_weight:
			valid_entries.erase(chosen_entry)
			continue

		var max_amount = int(remaining_weight / weight_per_unit)
		max_amount = min(max_amount, chosen_entry.amount_max)
		var entry_min = chosen_entry.amount_min

		if max_amount < entry_min:
			valid_entries.erase(chosen_entry)
			continue

		var amount = randi_range(entry_min, max_amount)

		var found = false
		for entry in result:
			if entry.item == chosen_entry.item:
				entry.amount += amount
				found = true
				break
		if not found:
			result.append({"item": chosen_entry.item.duplicate(), "amount": amount})

		remaining_weight -= amount * weight_per_unit

	return result


func _weighted_pick(entries: Array[LootEntry]) -> LootEntry:
	var total = 0
	for e in entries:
		total += e.weight
	if total <= 0:
		return null

	var pick = randi_range(1, total)
	var running = 0
	for e in entries:
		running += e.weight
		if pick <= running:
			return e
	return null
		
	
	
