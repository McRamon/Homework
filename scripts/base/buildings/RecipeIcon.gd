extends Button

var recipe: Recipe

func set_recipe(r):
	recipe = r
	text = r.name
	icon= r.icon
