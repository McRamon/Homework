extends Resource
class_name Recipe

@export var name: String
@export var icon: Texture2D
@export var input: Dictionary = {}   # { "wood": 2 }
@export var output: Dictionary = {}  # { "plank": 1 }
@export var duration: float = 5.0    # время крафта в секундах
