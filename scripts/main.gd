# res://Scripts/main.gd
extends Node2D

@export var house_scene: PackedScene
@export var barn_scene:  PackedScene
@export var mill_scene:  PackedScene

# текущая сцена и её footprint/cost
var _mode_scene: PackedScene
var _mode_footprint: Vector2i = Vector2i(1, 1)
var _mode_cost: Dictionary = {}

# ghost-превью
var _ghost: Sprite2D
var _placing := false

# pending-координаты до подтверждения
var _pending_cell
var _pending_snap

# занятые клетки
var _occupied := {}  # Dictionary<Vector2i, bool>

func _ready() -> void:
	# 1) Ghost-превью
	_ghost = Sprite2D.new()
	add_child(_ghost)
	_ghost.visible = false

	# 2) UI-кнопки
	$CanvasLayer/HouseButton.pressed.connect(self._on_house_button)
	$CanvasLayer/BarnButton.pressed.connect(self._on_barn_button)
	$CanvasLayer/MillButton.pressed.connect(self._on_mill_button)

	# 3) Диалог подтверждения
	var dlg = $CanvasLayer/PlaceDialog as ConfirmationDialog
	dlg.ok_button_text     = "OK"
	dlg.cancel_button_text = "Отмена"
	dlg.connect("confirmed", Callable(self, "_on_place_confirmed"))
	dlg.connect("canceled",   Callable(self, "_on_place_cancelled"))

	# 4) Включаем процесс
	set_process(true)

func _on_house_button() -> void:
	_start_placing(house_scene)

func _on_barn_button() -> void:
	_start_placing(barn_scene)

func _on_mill_button() -> void:
	_start_placing(mill_scene)

func _start_placing(scene: PackedScene) -> void:
	_mode_scene = scene

	# инстанс только ради footprint и cost
	var tmp = scene.instantiate() as Area2D
	if tmp.has_method("get_footprint"):
		_mode_footprint = tmp.get_footprint()
	else:
		_mode_footprint = Vector2i(1, 1)
	_mode_cost = tmp.cost
	_ghost.texture = tmp.get_node("Sprite2D").texture
	tmp.queue_free()

	_ghost.modulate = Color(0, 1, 0, 0.5)
	_ghost.visible  = true
	_placing        = true

func _process(_delta: float) -> void:
	# обновляем состояние кнопок
	_update_build_buttons()

	if not _placing:
		return

	# привязка к сетке 32×32
	var mp   = get_viewport().get_mouse_position()
	var cell = Vector2i(int(mp.x / 32), int(mp.y / 32))
	var snap = Vector2(cell.x * 32, cell.y * 32)

	# проверка footprint
	var can_place = true
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			if _occupied.has(cell + Vector2i(dx, dy)):
				can_place = false
				break
		if not can_place:
			break

	# рисуем ghost
	var center_pos = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	_ghost.global_position = snap + center_pos
	_ghost.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

	# ЛКМ — показ диалога; ПКМ — отмена
	if can_place and Input.is_action_just_pressed("mouse_left"):
		_pending_cell = cell
		_pending_snap = snap
		$CanvasLayer/PlaceDialog.popup_centered()
	elif Input.is_action_just_pressed("mouse_right"):
		_cancel_placing()

func _update_build_buttons() -> void:
	var rm = $ResourceManager
	_set_button_state($CanvasLayer/HouseButton, rm.can_afford(_get_cost(house_scene)))
	_set_button_state($CanvasLayer/BarnButton,  rm.can_afford(_get_cost(barn_scene)))
	_set_button_state($CanvasLayer/MillButton,  rm.can_afford(_get_cost(mill_scene)))

func _set_button_state(btn: Button, can_buy: bool) -> void:
	btn.disabled = not can_buy
	btn.modulate = Color(1, 1, 1, 1) if can_buy else Color(1, 1, 1, 0.5)

func _get_cost(scene: PackedScene) -> Dictionary:
	var tmp = scene.instantiate() as Area2D
	var c = tmp.cost
	tmp.queue_free()
	return c

func _on_place_confirmed() -> void:
	var rm = $ResourceManager
	if rm.can_afford(_mode_cost):
		rm.spend(_mode_cost)
		_place_building(_pending_cell, _pending_snap)
	else:
		print("Недостаточно ресурсов:", _mode_cost)

	_pending_cell = null
	_pending_snap = null

func _on_place_cancelled() -> void:
	if _pending_cell != null:
		for dx in range(_mode_footprint.x):
			for dy in range(_mode_footprint.y):
				_occupied.erase(_pending_cell + Vector2i(dx, dy))
	_cancel_placing()
	_pending_cell = null
	_pending_snap = null

func _place_building(cell: Vector2i, snap: Vector2) -> void:
	# резервируем footprint
	for dx in range(_mode_footprint.x):
		for dy in range(_mode_footprint.y):
			_occupied[cell + Vector2i(dx, dy)] = true

	var bld = _mode_scene.instantiate() as Area2D
	var center_pos = Vector2(32, 32) * 0.5 * Vector2(_mode_footprint.x, _mode_footprint.y)
	bld.global_position = snap + center_pos
	$Buildings.add_child(bld)
	bld.start_build()

	_ghost.visible = false
	_placing       = false

func _cancel_placing() -> void:
	_ghost.visible = false
	_placing       = false
