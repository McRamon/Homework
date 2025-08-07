# res://Base/Code/autoloads/ResourceManager.gd
extends Node


signal resource_changed(type: String, amount: int)

var resources      : Dictionary = {}  # { "wood": 100 }
var resource_items : Dictionary = {}  # { "wood": Item  }
var resource_icons : Dictionary = {}  # { "wood": Texture2D }

func _ready() -> void:
	# Регистрация начальных ресурсов
	var wood  = load("res://Base/Res/wood.tres")  as Item
	var stone = load("res://Base/Res/stone.tres") as Item
	var plank = load("res://Base/Res/plank.tres") as Item

	register_resource(wood,  100)
	register_resource(stone, 50)
	register_resource(plank, 10)

func register_resource(item: Item, start_amount: int = 0) -> void:
	var id = item.name.to_lower()
	if id in resources:
		return
	resources[id]      = start_amount
	resource_items[id] = item
	resource_icons[id] = item.spritesheet.get_frame_texture(item.get_animation("ui"), 0)
	emit_signal("resource_changed", id, start_amount)

func get_item(id: String) -> Item:
	return resource_items.get(id)

func get_amount(id: String) -> int:
	return resources.get(id, 0)

func add_resource(id: String, amount: int) -> void:
	var new_amt = max(get_amount(id) + amount, 0)
	resources[id] = new_amt
	emit_signal("resource_changed", id, new_amt)

func can_afford(requirements: Array) -> bool:
	for req in requirements:
		# 1) Определяем, где лежит Item и количество
		var item : Item
		var need : int

		if req.has("resource") and req.has("amount"):
			item = req["resource"] as Item
			need = req["amount"]
		elif req.has("Item") and req.has("amount"):
			item = req["Item"] as Item
			need = req["amount"]
		else:
			# нет нужных полей — пропускаем
			continue

		# 2) Проверяем наличие
		var id = item.name.to_lower()
		if get_amount(id) < need:
			return false
	return true

func spend(requirements: Array) -> void:
	# сначала убеждаемся, что можем списать
	if not can_afford(requirements):
		push_warning("ResourceManager: недостаточно ресурсов для этого рецепта")
		return

	# затем списываем по тому же алгоритму
	for req in requirements:
		var item : Item
		var need : int

		if req.has("resource") and req.has("amount"):
			item = req["resource"] as Item
			need = req["amount"]
		elif req.has("Item") and req.has("amount"):
			item = req["Item"] as Item
			need = req["amount"]
		else:
			continue

		var id = item.name.to_lower()
		add_resource(id, -need)
