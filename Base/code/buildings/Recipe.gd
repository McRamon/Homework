extends Resource
class_name Recipe

@export var name: String
@export var icon: Texture2D
@export var input: Array[Dictionary] = []   # [{ "resource": wood, "amount": 5 }]
@export var output: Array[Dictionary] = []  # [{ "resource": plank, "amount": 1 }]
@export var duration: float = 5.0
