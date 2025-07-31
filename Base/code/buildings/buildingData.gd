extends Resource
class_name BuildingData

@export var name: String
@export var icon_preview: Texture2D       # Превью для UI и ghost
@export var built_texture: Texture2D      # Текстура готового здания
@export var scene: PackedScene            # Универсальная сцена (Area2D)
@export var footprint: Vector2i = Vector2i.ONE
@export var cost: Dictionary = {"wood": 0, "stone": 0}
@export var build_time: float = 3.0
