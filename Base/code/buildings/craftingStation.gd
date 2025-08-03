extends Node

var current_recipe: Recipe = null
var progress: float = 0.0

func add_to_queue(recipe: Recipe):
	if not ResourceManager.can_afford(recipe.input):
		print("Недостаточно ресурсов для:", recipe.name)
		return

	ResourceManager.spend(recipe.input)
	current_recipe = recipe
	progress = 0.0
	print("Начало крафта:", recipe.name)

func _process(delta):
	if current_recipe:
		progress += delta
		if progress >= current_recipe.duration:
			_finish_craft()

func _finish_craft():
	for out in current_recipe.output:
		ResourceManager.add_resource(out["resource"].name, out["amount"])
	print("Крафт завершен:", current_recipe.name)
	current_recipe = null
