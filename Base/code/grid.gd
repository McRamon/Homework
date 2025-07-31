# res://Scripts/Grid.gd
extends Node2D

@export var cell_size: Vector2 = Vector2(32, 32)
@export var line_color: Color = Color(1, 1, 1, 0.2)

func _ready() -> void:
	# Перерисовать сразу
	queue_redraw()
	# И при любом изменении размера вьюпорта
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))

func _on_viewport_resized() -> void:
	queue_redraw()

func _draw() -> void:
	var sz = get_viewport_rect().size
	# Вертикальные линии
	var x = 0.0
	while x < sz.x:
		draw_line(Vector2(x, 0), Vector2(x, sz.y), line_color)
		x += cell_size.x
	# Горизонтальные линии
	var y = 0.0
	while y < sz.y:
		draw_line(Vector2(0, y), Vector2(sz.x, y), line_color)
		y += cell_size.y
