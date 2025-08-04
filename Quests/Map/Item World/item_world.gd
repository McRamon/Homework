extends Node2D
class_name ItemWorld

var drop_radius: float = 50.0
var drop_heigt:float = 30.0
var drop_time: float = 0.5

@onready var sprite: AnimatedSprite2D

var item_data: Item
var item_amount: int
var target_position: Vector2
var active: bool = false

func setup(data: Item, amount: int):
	sprite = $item_sprite
	item_data = data
	item_amount = amount
	var label = $Label
	label.text = str(item_data.name, item_amount)
	print("DROPPED ITEM SETUP: ", item_data.name)
	if sprite:
		print("Before sprite_frames set:", sprite.sprite_frames)
		sprite.sprite_frames = item_data.spritesheet
		sprite.play(item_data.get_animation("icon"))
		print("After sprite_frames set:", sprite.sprite_frames)
	else:
		print("No sprite node found!")
	

func _ready():
	if sprite == null:
		print("No sprite node found in _ready!")
	else:
		print("Sprite node found:", sprite)
	if item_data:
		sprite.sprite_frames = item_data.spritesheet
		sprite.play(item_data.get_animation("icon"))
	var random_angle = randf() * TAU
	var random_distance = randf_range(drop_radius, drop_radius/2)
	target_position = position + Vector2.RIGHT.rotated(random_angle) * random_distance
	
	var start_position = position
	position = start_position
	
	_play_drop_animation(start_position, target_position)


func _play_drop_animation(start_pos: Vector2, end_pos: Vector2):
	var tween = create_tween()
	var peak_pos = (start_pos + end_pos) * 0.5
	peak_pos.y -= drop_heigt
	
	tween.tween_property(self, "position", peak_pos, drop_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", end_pos, drop_time * 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(_on_drop_finished)
	
	
func _on_drop_finished():
	print("DROPPED: ", item_data.name, " - ", item_amount)
	active = true
