extends Node2D

@export var house_scene: PackedScene
@export var barn_scene:  PackedScene
@export var mill_scene:  PackedScene

# текущая сцена и её footprint
var _mode_scene: PackedScene
var _mode_footprint: Vector2i = Vector2i(1, 1)

# ghost-превью
var _ghost: Sprite2D
var _placing := false

# pending-координаты до подтверждения
var _pending_cell
var _pending_snap

# занятые клетки (Vector2i → bool)
var _occupied := {}

func _ready() -> void:
	# создаём ghost
	_ghost = Sprite2D.new()
	add_child(_ghost)
	_ghost.visible = false

	# UI-кнопки
	$CanvasLayer/HouseButton.pressed.connect(self._on_house_button)
	$CanvasLayer/BarnButton.pressed.connect(self._on_barn_button)
	$CanvasLayer/MillButton.pressed.connect(self._on_mill_button)

	# ConfirmationDialog под CanvasLayer, имя — PlaceDialog
	var dlg = $CanvasLayer/PlaceDialog as ConfirmationDialog
	dlg.ok_button_text     = "OK"
	dlg.cancel_button_text = "Отмена"
	dlg.connect("confirmed", Callable(self, "_on_place_confirmed"))
	dlg.connect("canceled",   Callable(self, "_on_place_cancelled"))

	set_process(true)

func _on_house_button() -> void:
	_start_placing(house_scene)
func _on_barn_button() -> void:
	_start_placing(barn_scene)
func _on_mill_button() -> void:
	_start_placing(mill_scene)

func _start_placing(scene: PackedScene) -> void:
	_mode_scene = scene
	# инстанс для получения footprint и текстуры
	var tmp = scene.instantiate() as Node2D
	if tmp.has_method("get_footprint"):
		_mode_footprint = tmp.call("get_footprint")
	else:
		_mode_footprint = Vector2i(1,1)
	_ghost.texture = tmp.get_node("Sprite2D").texture
	tmp.queue_free()

	_ghost.modulate = Color(0,1,0,0.5)
	_ghost.visible  = true
	_placing        = true

func _process(_delta: float) -> void:
	if not _placing:
		return

	# привязка курсора к сетке 32×32
	var mp   = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 32), int(mp.y / 32))
	var snap = Vector2(cell.x * 32, cell.y * 32)

	# проверяем **только** footprint-клетки (без буфера)
	var can_place = true
	for dx in range(0, _mode_footprint.x):
		for dy in range(0, _mode_footprint.y):
			if _occupied.has(cell + Vector2i(dx,dy)):
				can_place = false
				break
		if not can_place:
			break

	# рисуем ghost
	var center = Vector2(32,32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center
	if can_place:
		_ghost.modulate = Color(0,1,0,0.5)
	else:
		_ghost.modulate = Color(1,0,0,0.5)

	# ЛКМ — показываем диалог, ПКМ — отменяем
	if can_place and Input.is_action_just_pressed("mouse_left"):
		_pending_cell = cell
		_pending_snap = snap
		$CanvasLayer/PlaceDialog.popup_centered()
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_placing()

func _on_place_confirmed() -> void:
	# OK — строим
	if _pending_cell != null and _pending_snap != null:
		_place_building(_pending_cell, _pending_snap)
	_pending_cell = null
	_pending_snap = null

func _on_place_cancelled() -> void:
	# Отмена — освобождаем pending-клетки
	if _pending_cell != null:
		for dx in range(_mode_footprint.x):
			for dy in range(_mode_footprint.y):
				_occupied.erase(_pending_cell + Vector2i(dx,dy))
	_cancel_placing()
	_pending_cell = null
	_pending_snap = null

func _place_building(cell: Vector2i, snap: Vector2) -> void:
	# резервируем сами footprint-клетки
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			_occupied[cell + Vector2i(dx,dy)] = true

	# инстансим здание и запускаем его таймер
	var bld = _mode_scene.instantiate() as Area2D
	var center = Vector2(32,32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	bld.global_position = snap + center
	$Buildings.add_child(bld)
	bld.start_build()

	_ghost.visible = false
	_placing       = false

func _cancel_placing() -> void:
	_ghost.visible = false
	_placing       = false
