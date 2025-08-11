extends ItemContainer
class_name PlayerBag


#func _generate_loot():
	#items.clear()
	#for i in size:
		#items.append(null)
	#print("---------NEW LOOT GENERATION------------")
	#var loot_table := LootTable.new()
	#
	#var blue_ball := LootEntry.new()
	#blue_ball.item = preload("res://Code/Items/Test Items/ball_blue.tres").duplicate()
	#blue_ball.amount_min = 1
	#blue_ball.amount_max = 2
	#blue_ball.weight = 2
	#blue_ball.unit_weight = 10
#
	#var green_ball := LootEntry.new()
	#green_ball.item = preload("res://Code/Items/Test Items/ball_green.tres").duplicate()
	#green_ball.amount_min = 1
	#green_ball.amount_max = 10
	#green_ball.weight = 5
	#green_ball.unit_weight = 5
	#
	#var purple_ball := LootEntry.new()
	#purple_ball.item = preload("res://Code/Items/Test Items/ball_purple.tres").duplicate()
	#purple_ball.amount_min = 5
	#purple_ball.amount_max = 15
	#purple_ball.weight = 15
	#purple_ball.unit_weight = 1
#
	#loot_table.loot_entries = [blue_ball,green_ball, purple_ball]
	#loot_table.total_weight = 15
#
	#var result = loot_table.generate_loot()
	#for entry in result:
		#add_item(entry.item.duplicate(), entry.amount)
	#print(" GENERATED LOOT: ")
	#for e in result:
		#print("  • ", e.item.name, 
		  #"| Amount:", e.amount)
	#print(result)
