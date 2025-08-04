extends Area2D
signal build_completed

enum BuildState { CONSTRUCTING, BUILT }

@export var footprint: Vector2i = Vector2i.ONE
@onready var sprite: Sprite2D = $Sprite2D
@onready var countdown: Label = $CountdownLabel if has_node("CountdownLabel") else null

var state: BuildState = BuildState.BUILT
var time_left: float = 0.0

func get_footprint() -> Vector2i:
	return footprint

func start_build(duration: float):
	state = BuildState.CONSTRUCTING
	time_left = duration
	modulate = Color(1, 1, 1, 0.5)
	if countdown:
		countdown.visible = true
		countdown.text = _format_time(time_left)
	set_process(true)

func _process(delta):
	if state == BuildState.CONSTRUCTING:
		time_left -= delta
		if countdown:
			countdown.text = _format_time(time_left)
		if time_left <= 0:
			_finish_build()

func _finish_build():
	state = BuildState.BUILT
	modulate = Color(1, 1, 1, 1)
	if countdown:
		countdown.visible = false
	set_process(false)
	emit_signal("build_completed")

func _format_time(t: float) -> String:
	var s = int(ceil(t))
	var m = s / 60
	var sec = s % 60
	return "%02d:%02d" % [m, sec]
