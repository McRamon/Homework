extends Camera2D

@export var target: Node2D = null
@export var smoothing_speed: float = 10.0
@export var snapper: float = 1.5

var zoom_speed: float = 10
var zoom_min: float = 2
var zoom_max: float = 6

var target_zoom: float = 1.0

func _ready():
	await get_tree().process_frame
	if !target:
		for gaybaby in owner.get_children():
			if gaybaby.is_in_group("player_character"):
				target = gaybaby
		

func _process(delta):
	if target:
		var new_pos = lerp(global_position, target.global_position, delta * smoothing_speed)
		if global_position.distance_to(target.global_position) < snapper:
			new_pos = target.global_position
		global_position = new_pos
		
	if Input.is_action_just_pressed("mouse_wheel_up"):
		target_zoom += 0.1
	if Input.is_action_just_pressed("mouse_wheel_down"):
		target_zoom -= 0.1
		
	target_zoom = clamp(target_zoom, zoom_min, zoom_max)
	zoom = lerp(zoom, Vector2(target_zoom, target_zoom), delta * zoom_speed)

# Switch to follow a new target (e.g., cutscene focus)
func set_target(new_target: Node2D):
	target = new_target
