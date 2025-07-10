# res://Scripts/Building.gd
extends Area2D

@export var footprint: Vector2i = Vector2i(1, 1)
@export var build_time: float  = 3.0

# автоматически найдёт твой Label и Shape
@onready var countdown_label: Label = $CountdownLabel
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _time_left := 0.0
var _in_progress := false

func get_footprint() -> Vector2i:
	return footprint

# Запускается из main.gd: bld.start_build()
func start_build() -> void:
	# 1) Переключаем в «черновик»
	modulate = Color(1,1,1,0.5)
	collision_shape.disabled = true

	# 2) Показываем Label и готовим счётчик
	countdown_label.visible = true
	_time_left = build_time
	_in_progress = true

	# 3) Включаем _process() для обновления счётчика
	set_process(true)
	_update_label()

func _process(delta: float) -> void:
	if not _in_progress:
		return

	_time_left = max(_time_left - delta, 0)
	_update_label()

	if _time_left <= 0:
		_on_build_complete()

func _update_label() -> void:
	# берём общее оставшееся время в секундах (целое)
	var total_seconds = int(ceil(_time_left))
	# вычисляем часы, минуты и секунды
	var hours   = total_seconds / 3600
	var minutes = (total_seconds / 60) % 60
	var seconds = total_seconds % 60
	# форматируем с ведущими нулями: "HH:MM:SS"
	countdown_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _on_build_complete() -> void:
	# 1) Финализируем внешность
	modulate = Color(1,1,1,1)
	collision_shape.disabled = false
	countdown_label.visible = false

	# 2) Выключаем процесс
	_in_progress = false
	set_process(false)

	# сюда же можно добавить любые анимации, звуки и т.п.
