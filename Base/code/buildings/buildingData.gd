extends Item
class_name BuildingData

# Сцена префаб здания
@export var building_scene     : PackedScene
# Опциональная позиция спавна (локальные координаты в сцене)
@export var spawn_position     : Vector2 = Vector2.ZERO

# Материалы для строительства
@export var requirement_items   : Array[Item] = []
@export var requirement_amounts : Array[int]  = []

# Время строительства (в секундах)
@export var build_time         : float = 2.0

# Размер постройки в клетках (ширина × высота)
@export var size              : Vector2i = Vector2i(1, 1)
