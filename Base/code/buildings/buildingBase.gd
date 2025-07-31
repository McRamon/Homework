extends Area2D
signal build_completed

enum BuildState { CONSTRUCTING, BUILT }

@export var footprint: Vector2i = Vector2i.ONE
@export var construction_texture: Texture2D
@export var built_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var CountdownLabel: Label = $CountdownLabel

var state: BuildState = BuildState.BUILT
var time_left: float = 0.0

func get_footprint() -> Vector2i:
	return footprint

func start_build(duration: float):
	state = BuildState.CONSTRUCTING
	time_left = duration

	if construction_texture:
		sprite.texture = construction_texture

	modulate = Color(1, 1, 1, 0.5)
	CountdownLabel.visible = true
	CountdownLabel.text = _format_time(time_left)
	set_process(true)

func _process(delta):
	if state == BuildState.CONSTRUCTING:
		time_left -= delta
		if time_left < 0: time_left = 0
		CountdownLabel.text = _format_time(time_left)
		if time_left <= 0:
			_finish_build()

func _finish_build():
	state = BuildState.BUILT
	if built_texture:
		sprite.texture = built_texture
	modulate = Color(1, 1, 1, 1)
	CountdownLabel.visible = false
	set_process(false)
	emit_signal("build_completed")

# Открытие окна крафта при клике
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if state == BuildState.BUILT:
			var ui = _find_crafting_ui()
			var station = get_node_or_null("CraftingStation")
			if ui and station:
				ui.open_for_station(station)

func _find_crafting_ui():
	var root = get_tree().get_root()
	return root.find_child("CraftingUI", true, false)

func _format_time(t: float) -> String:
	var total_seconds = int(ceil(t))
	var h = total_seconds / 3600
	var m = (total_seconds / 60) % 60
	var s = total_seconds % 60
	return "%02d:%02d:%02d" % [h, m, s]
