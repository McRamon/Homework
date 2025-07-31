extends Node
class_name MovementComponent

#mob basic stats
@export var speed:= 100.0
var current_speed: float

@export var weight:= 100 #Эта переменная отвечает за то, насколько быстро будет останавливаться моб после разного рода отталкиваний.

var mob: Node2D
var direction:= Vector2.ZERO
var external_force:= Vector2.ZERO
var current_velocity := Vector2.ZERO
var speed_modifier:= 1.0

var can_move: bool = true


func _ready():
	mob = get_parent() as CharacterBody2D
	current_speed = speed
	
func _process(delta):
	if direction != Vector2.ZERO:
		current_velocity = direction.normalized() * current_speed
		
	if external_force.length_squared() > 0.01:
		current_velocity += external_force
		apply_drag(delta)
		
	mob.velocity = current_velocity
	mob.move_and_slide()
		
func push(force: Vector2):
	external_force += force
	
func apply_drag(delta):
	var decay = weight * delta
	if external_force.length() <= decay:
		external_force = Vector2.ZERO
	else:
		external_force -= external_force.normalized() * decay
