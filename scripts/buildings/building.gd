# res://Scripts/Building.gd
extends Area2D

@export var footprint: Vector2i = Vector2i(1, 1)
@export var build_time: float   = 3.0
@export var cost: Dictionary    = {"wood": 10, "stone": 5}

@onready var cost_label:       Label            = $CostLabel
@onready var countdown_label:  Label            = $CountdownLabel
@onready var collision_shape:  CollisionShape2D = $CollisionShape2D

var _time_left:   float = 0.0
var _in_progress: bool  = false

func _ready() -> void:
	# При загрузке сцены сразу показываем стоимость
	_update_cost_label()
	cost_label.visible = true
	countdown_label.visible = false
	collision_shape.disabled = false

func get_footprint() -> Vector2i:
	return footprint

func start_build() -> void:
	# Входим в режим строительства
	modulate = Color(1,1,1,0.5)
	collision_shape.disabled = true

	# Скрываем cost_label, показываем таймер
	cost_label.visible = false
	countdown_label.visible = true

	_time_left    = build_time
	_in_progress  = true
	set_process(true)
	_update_countdown()

func _process(delta: float) -> void:
	if not _in_progress:
		return
	_time_left = max(_time_left - delta, 0)
	_update_countdown()
	if _time_left <= 0:
		_on_build_complete()

func _update_countdown() -> void:
	var total_seconds = int(ceil(_time_left))
	var hours   = total_seconds / 3600
	var minutes = (total_seconds / 60) % 60
	var seconds = total_seconds % 60
	countdown_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _on_build_complete() -> void:
	# Завершаем строительство
	modulate = Color(1,1,1,1)
	collision_shape.disabled = false
	countdown_label.visible = false
	_in_progress = false
	set_process(false)

func _update_cost_label() -> void:
	# Формируем текст вида:
	# wood: 10
	# stone: 5
	var lines := []
	for resource in cost.keys():
		lines.append("%s: %d" % [resource, cost[resource]])
	cost_label.text = String("\n").join(lines)
