extends Node
signal resource_changed(type: String, amount: int)

var resources: Dictionary = {}      # { "wood": 100, "stone": 50 }
var resource_icons: Dictionary = {} # { "wood": Texture2D, "stone": Texture2D }

func _ready():
	# Загружаем ресурсы
	var wood = load("res://Base/Res/wood.tres") as ResourceData
	var stone = load("res://Base/Res/stone.tres") as ResourceData

	register_resource(wood.id, wood.icon, 100)
	register_resource(stone.id, stone.icon, 50)

	print("✅ Ресурсы инициализированы:", resources)

func register_resource(id: String, icon: Texture2D, start_amount: int = 0):
	if id in resources: return
	resources[id] = start_amount
	resource_icons[id] = icon
	emit_signal("resource_changed", id, start_amount)

func add_resource(id: String, amount: int):
	resources[id] = resources.get(id, 0) + amount
	emit_signal("resource_changed", id, resources[id])

func get_amount(id: String) -> int:
	return resources.get(id, 0)

func can_afford(requirements: Array) -> bool:
	for req in requirements:
		var res: ResourceData = req["resource"]
		var amount = req["amount"]
		if resources.get(res.id, 0) < amount:
			return false
	return true

func spend(requirements: Array):
	for req in requirements:
		var res: ResourceData = req["resource"]
		var amount = req["amount"]
		add_resource(res.id, -amount)
