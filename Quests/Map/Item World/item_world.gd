extends Node2D
class_name ItemWorld

var drop_radius: float = 50.0
var drop_heigt:float = 30.0
var drop_time: float = 0.5

var pickup_speed: float = 400
var pickup_range = 10

@onready var sprite: AnimatedSprite2D
@onready var pickup_area: Area2D = $pickup_area
var player_target: CharacterBody2D = null

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
	pickup_area.body_entered.connect(_on_body_entered)
	pickup_area.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_target and active:
		var direction = (player_target.global_position - global_position).normalized()
		position += direction * pickup_speed * delta
	
		
		if global_position.distance_to(player_target.global_position) <= pickup_range:
			if player_target.player_inventory:
				player_target.player_inventory.add_item(item_data, item_amount)
			print("PICKED UP ITEM: ", item_data, " = ", item_amount)
			print(" CURRENT BAG CONTENTS: ", player_target.player_inventory.items)
			queue_free()
				
		

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
	
func _on_body_entered(body):
	player_target = body
func _on_body_exited(body):
	player_target = null
