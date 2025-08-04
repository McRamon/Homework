extends Node
signal resource_changed(type: String, amount: int)

var resources: Dictionary = {}        # { "wood": 100 }
var resource_items: Dictionary = {}   # { "wood": Item }
var resource_icons: Dictionary = {}   # { "wood": Texture2D } (по желанию)

func _ready():
	var wood = load("res://Base/Res/wood.tres") as ItemMaterial
	var stone = load("res://Base/Res/stone.tres") as ItemMaterial

	register_resource(wood, 100)
	register_resource(stone, 50)

	print("✅ Ресурсы инициализированы:", resources)

# 🔹 Регистрирует ресурс по объекту Item
func register_resource(item: Item, start_amount: int = 0):
	var id := item.name.to_lower()

	if id in resources:
		return

	resources[id] = start_amount
	resource_items[id] = item
	resource_icons[id] = item.spritesheet.get_frame_texture(item.get_animation("ui"), 0)

	emit_signal("resource_changed", id, start_amount)

# 🔹 Возвращает Item по его id
func get_item(id: String) -> Item:
	return resource_items.get(id)

# 🔹 Добавить/убавить количество ресурса
func add_resource(id: String, amount: int):
	resources[id] = resources.get(id, 0) + amount
	emit_signal("resource_changed", id, resources[id])

# 🔹 Получить количество
func get_amount(id: String) -> int:
	return resources.get(id, 0)

# 🔹 Проверка: хватает ли ресурсов
func can_afford(requirements: Array) -> bool:
	for req in requirements:
		if not req.has("resource") or not req.has("amount"):
			continue

		var res: Item = req["resource"]
		var amount: int = req["amount"]
		var id := res.name.to_lower()

		if get_amount(id) < amount:
			return false
	return true

# 🔹 Списать ресурсы
func spend(requirements: Array):
	for req in requirements:
		if not req.has("resource") or not req.has("amount"):
			continue

		var res: Item = req["resource"]
		var amount: int = req["amount"]
		var id := res.name.to_lower()

		add_resource(id, -amount)
