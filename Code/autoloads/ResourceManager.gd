# ResourceManager.gd
extends Node


signal resource_changed(type: String, amount: int)

var resources: Dictionary = {}        # { "wood": 100 }
var resource_items: Dictionary = {}   # { "wood": Item }
var resource_icons: Dictionary = {}   # { "wood": Texture2D }

func _ready():
	var wood = load("res://Base/Res/wood.tres") as ItemMaterial
	var stone = load("res://Base/Res/stone.tres") as ItemMaterial	
	var plank = load("res://Base/Res/plank.tres") as ItemMaterial

	register_resource(wood, 100)
	register_resource(stone, 50)
	register_resource(plank, 10)
	print("✅ Ресурсы инициализированы:", resources)

func register_resource(item: Item, start_amount: int = 0):
	var id := item.name.to_lower()
	if id in resources:
		return
	resources[id] = start_amount
	resource_items[id] = item
	resource_icons[id] = item.spritesheet.get_frame_texture(item.get_animation("ui"), 0)
	emit_signal("resource_changed", id, start_amount)

func get_item(id: String) -> Item:
	return resource_items.get(id)

func add_resource(id: String, amount: int):
	resources[id] = resources.get(id, 0) + amount
	emit_signal("resource_changed", id, resources[id])

func get_amount(id: String) -> int:
	return resources.get(id, 0)

func can_afford(requirements: Array) -> bool:
	for req in requirements:
		if not (req.has("resource") and req.has("amount")):
			continue
		var res: Item  = req["resource"]
		var amt: int   = req["amount"]
		if get_amount(res.name.to_lower()) < amt:
			return false
	return true

func spend(requirements: Array):
	for req in requirements:
		if not (req.has("resource") and req.has("amount")):
			continue
		var res: Item  = req["resource"]
		var amt: int   = req["amount"]
		add_resource(res.name.to_lower(), -amt)
