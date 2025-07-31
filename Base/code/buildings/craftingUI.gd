extends PopupPanel

var station: Node = null

func open_for_station(crafting_station):
	station = crafting_station
	_populate_recipes()
	popup_centered()

func _populate_recipes():
	var container = $VBoxContainer
	for child in container.get_children():
		child.queue_free()

	for recipe in station.recipes:
		var btn = Button.new()
		btn.text = "%s (%.1f сек)" % [recipe.name, recipe.duration]
		btn.connect("pressed", func():
			station.add_to_queue(recipe)
			hide()
		)
		container.add_child(btn)

func _on_CloseButton_pressed():
	hide()
