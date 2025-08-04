extends ItemContainer
class_name LootContainer

@export var loot_table: LootTable


func _generate_loot():
	items.clear()
	for i in size:
		items.append(null)
	print("---------NEW LOOT GENERATION------------")
	var loot_gen := LootGenerator.new()
	if loot_table:
		loot_gen.loot_entries = loot_table.loot_entries
		loot_gen.total_weight = loot_table.total_weight
	var result = loot_gen.generate_loot()
	for entry in result:
		add_item(entry.item.duplicate(), entry.amount)
	print(" GENERATED LOOT: ")
	for e in result:
		print("  • ", e.item.name, 
		  "| Amount:", e.amount)
	print(result)
