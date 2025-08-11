extends Resource
class_name BuildingData

@export var name: String
@export var menu_icon: Texture2D
@export var preview_icon: Texture2D
@export var scene: PackedScene

@export var footprint: Vector2i = Vector2i.ONE
@export var build_time: float = 3.0

# 🔹 Требования: [{ "resource": Item, "amount": int }]
@export var build_requirements: Array[Dictionary] = []
