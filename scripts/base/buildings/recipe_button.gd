extends Button

var recipe: Recipe

func setup(_recipe: Recipe):
	recipe = _recipe
	text = recipe.name
	# Можно добавить иконку, если надо:
	# self.icon = recipe.icon

func _on_pressed():
	# Это обработается в родительском контроллере через connect
	emit_signal("pressed")
