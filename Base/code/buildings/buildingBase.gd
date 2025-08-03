extends Area2D
signal build_completed

enum BuildState { CONSTRUCTING, BUILT }



@export var footprint: Vector2i = Vector2i.ONE



@onready var sprite: Sprite2D = $Sprite2D
@onready var CountdownLabel: Label = $CountdownLabel if has_node("CountdownLabel") else null

var state: BuildState = BuildState.BUILT
var time_left: float = 0.0

func get_footprint() -> Vector2i:
	return footprint

func start_build(duration: float):
	state = BuildState.CONSTRUCTING
	time_left = duration



	modulate = Color(1, 1, 1, 0.5)
	if CountdownLabel:
		CountdownLabel.visible = true
		CountdownLabel.text = _format_time(time_left)

	set_process(true)

func _process(delta):
	if state == BuildState.CONSTRUCTING:
		time_left -= delta
		if time_left < 0:
			time_left = 0

		if CountdownLabel:
			CountdownLabel.text = _format_time(time_left)

		if time_left <= 0:
			_finish_build()

func _finish_build():
	state = BuildState.BUILT



	modulate = Color(1, 1, 1, 1)
	if CountdownLabel:
		CountdownLabel.visible = false
	set_process(false)
	emit_signal("build_completed")

# Клик по зданию (открыть крафт)
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
