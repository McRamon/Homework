# res://Scripts/Building.gd
extends Node2D

# footprint — сколько клеток по X и Y занимает это здание
@export var footprint: Vector2i = Vector2i(1, 1)

func get_footprint() -> Vector2i:
	return footprint
