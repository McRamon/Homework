extends Camera2D

@export var target: Node2D
@export var smoothing_speed: float = 5.0

func _process(delta):
	if target:
		global_position = lerp(global_position, target.global_position, delta * smoothing_speed)

# Instantly jump to a position (without smoothing)
func jump_to(position: Vector2):
	global_position = position

# Switch to follow a new target (e.g., cutscene focus)
func set_target(new_target: Node2D):
	target = new_target
