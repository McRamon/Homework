extends Node2D
class_name CraftingStation

@export var recipes: Array[ItemRecipe] = []

var queue: Array = []                # Очередь крафта
var finished_slots: Array = []       # Готовые предметы

var current_recipe: ItemRecipe = null
var progress: float = 0.0

# ✅ Добавляем рецепт в очередь
func add_to_queue(recipe: ItemRecipe):
	if not ResourceManager.can_afford(recipe.input):
		print("❌ Недостаточно ресурсов для:", recipe.name)
		return

	ResourceManager.spend(recipe.input)
	queue.append(recipe)
	print("➕ Рецепт добавлен в очередь:", recipe.name)

	if current_recipe == null:
		_start_next_craft()

# ✅ Запускаем следующий рецепт
func _start_next_craft():
	if queue.is_empty():
		current_recipe = null
		return

	current_recipe = queue.pop_front()
	progress = 0.0
	print("▶ Начало крафта:", current_recipe.name)

func _process(delta):
	if current_recipe:
		progress += delta
		if progress >= current_recipe.duration:
			_finish_craft()

# ✅ Завершение крафта
func _finish_craft():
	finished_slots.append({
		"recipe": current_recipe,
		"time": current_recipe.duration,
		"progress": current_recipe.duration
	})

	for out in current_recipe.output:
		var item: Item = out["resource"]
		var amount = out["amount"]
		ResourceManager.add_resource(item.name, amount)
		print("✅ Получено:", item.name, "+", amount)

	print("🎉 Крафт завершен:", current_recipe.name)
	current_recipe = null
	_start_next_craft()

# ✅ Сборка готового предмета (для UI)
func collect_slot(slot):
	finished_slots.erase(slot)
	print("📦 Забран результат крафта:", slot["recipe"].name)
