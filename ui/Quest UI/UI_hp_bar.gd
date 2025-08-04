extends Control
class_name UIHPBar

@export var health_component: HealthComponent
@export var bar_width: float = 60.0
var diminish_speed: float = 40.0
var shown_health: float

@onready var red_bar = $HP_Fill
@onready var white_bar = $HP_Damage
@onready var black_bar = $HP_Empty

func _ready():
	health_component = get_parent().get_node_or_null("HealthComponent")
	if not health_component:
		push_warning("Mob ", self, " - no HealthComponent found for HP bar")
		return
	
	await get_tree().process_frame
	shown_health = health_component.max_health
	health_component.health_changed.connect(_on_health_changed)
	
	_update_bar()
	
func _process(delta:float):
	if health_component and shown_health > health_component.current_health:
		shown_health = max(shown_health - diminish_speed * delta, health_component.current_health)
		_update_bar()
		
func _update_bar():
	if not health_component:
		return

	var current = health_component.current_health
	var max_val = health_component.max_health
	if health_component.current_health >= health_component.max_health:
		visible = false
	else:
		visible = true

	# Ratios
	var hp_ratio = clamp(float(current) / float(max_val), 0.0, 1.0)
	var dmg_ratio = clamp(float(shown_health - current) / float(max_val), 0.0, 1.0)
	var empty_ratio = 1.0 - hp_ratio - dmg_ratio

	# Apply widths
	red_bar.size.x = bar_width * hp_ratio
	white_bar.size.x = bar_width * dmg_ratio
	black_bar.size.x = bar_width * empty_ratio

	# Position bars sequentially
	red_bar.position.x = 0
	white_bar.position.x = red_bar.size.x
	black_bar.position.x = red_bar.size.x + white_bar.size.x
	
	red_bar.modulate = _get_hp_color(hp_ratio)
	
func _on_health_changed(old_value: int, new_value: int):
	shown_health = max(shown_health, old_value)
	_update_bar()
	
func _get_hp_color(hp_ratio: float) -> Color:
	var green = Color(0, 1, 0)
	var yellow = Color(1, 1, 0)
	var orange = Color(1, 0.5, 0)
	var red = Color(1, 0, 0)

	if hp_ratio >= 0.75:
		var t = (1 - hp_ratio) / 0.25
		return green.lerp(yellow, t) # green at 1, yellow at 0.75
	elif hp_ratio >= 0.5:
		var t = (0.75 - hp_ratio) / 0.25
		return yellow.lerp(orange, t) # yellow at 0.5, orange at 0.75
	else:
		var t = hp_ratio / 0.5
		return red.lerp(orange, t) # orange at 0.5, red at 0
	
	
