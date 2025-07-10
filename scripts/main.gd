extends Node2D

@export var house_scene: PackedScene
@export var barn_scene:  PackedScene
@export var mill_scene:  PackedScene

# текущая сцена и её footprint
var _mode_scene: PackedScene
var _mode_footprint: Vector2i = Vector2i(1, 1)

# ghost-спрайт
var _ghost: Sprite2D
var _placing := false

# какие клетки заняты (Vector2i -> bool)
var _occupied: Dictionary = {}

func _ready() -> void:
	# 1) Ghost
	_ghost = Sprite2D.new()
	_ghost.modulate = Color(0, 1, 0, 0.5)
	add_child(_ghost)
	_ghost.visible = false

	# 2) UI-кнопки
	$CanvasLayer/HouseButton.pressed.connect(self._on_house_button)
	$CanvasLayer/BarnButton.pressed.connect(self._on_barn_button)
	$CanvasLayer/MillButton.pressed.connect(self._on_mill_button)

	# 3) Процесс
	set_process(true)

func _on_house_button() -> void:
	_start_placing(house_scene)
func _on_barn_button() -> void:
	_start_placing(barn_scene)
func _on_mill_button() -> void:
	_start_placing(mill_scene)

func _start_placing(scene: PackedScene) -> void:
	_mode_scene = scene

	# Вытаскиваем footprint у сцены
	var tmp = _mode_scene.instantiate() as Node2D
	if tmp.has_method("get_footprint"):
		_mode_footprint = tmp.call("get_footprint")
	else:
		_mode_footprint = Vector2i(1, 1)
	# И текстуру ghost
	_ghost.texture = tmp.get_node("Sprite2D").texture
	tmp.queue_free()

	_ghost.modulate = Color(0, 1, 0, 0.5)
	_ghost.visible  = true
	_placing        = true

func _process(_delta: float) -> void:
	if not _placing:
		return

	# 1) Ячейка под мышью
	var mp   = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 64), int(mp.y / 64))
	var snap = Vector2(cell.x * 64, cell.y * 64)

	# 2) Проверка footprint + 1 клетка вокруг
	var can_place = true
	for dx in range(-1, _mode_footprint.x + 1):
		for dy in range(-1, _mode_footprint.y + 1):
			var check = cell + Vector2i(dx, dy)
			if _occupied.has(check):
				can_place = false
				break
		if not can_place:
			break

	# 3) Позиционируем и красим ghost
	var center_offset = Vector2(64, 64) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center_offset
	if can_place:
		_ghost.modulate = Color(0, 1, 0, 0.5)
	else:
		_ghost.modulate = Color(1, 0, 0, 0.5)

	# 4) ЛКМ — ставим, ПКМ — отменяем
	if can_place and Input.is_action_just_pressed("mouse_left"):
		_place_building(cell, snap)
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_placing()

func _place_building(cell: Vector2i, snap: Vector2) -> void:
	# Инстанс и позиция
	var bld = _mode_scene.instantiate() as Node2D
	var center_offset = Vector2(64, 64) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	bld.global_position = snap + center_offset
	$Buildings.add_child(bld)

	# Помечаем именно footprint-клетки занятыми
	for dx in range(0, _mode_footprint.x):
		for dy in range(0, _mode_footprint.y):
			var mark = cell + Vector2i(dx, dy)
			_occupied[mark] = true

	_ghost.visible = false
	_placing       = false

func _cancel_placing() -> void:
	_ghost.visible = false
	_placing       = false
