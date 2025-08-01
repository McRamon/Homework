extends Action
class_name DashAbility

@export var dash_distance: float = 150.0
@export var dash_speed: float = 150

@export var trail_scene: PackedScene
@export var trail_spawn_rate := 0.05
var _trail_timer := 0.0

var _movement_component: Node
var _remaining_distance: float
var _is_dashing:= false
var _dash_direction:= Vector2.ZERO

var _mob: CharacterBody2D

func activate(mob: CharacterBody2D, direction: Vector2):
	if not mob:
		return
	_mob = mob
	
	_movement_component = _mob.get_node_or_null("MovementComponent")
	if not _movement_component:
		push_warning("DashAbility: No MovementComponent found on mob")
	_is_dashing = true
	_dash_direction = direction
	_remaining_distance = dash_distance
	_movement_component.set_physics_process(false)
	_movement_component.enabled = false
	_mob.velocity = direction * dash_speed
	print("dash velocity set to: ", _mob.velocity)
	print("dash activated by ", mob)
	
	
func update(delta: float):
	if not _is_dashing:
		return
	
	var old_position = _mob.global_position
	_mob.velocity = _dash_direction * dash_speed
	_mob.move_and_slide()
	
	if _mob.global_position.distance_to(old_position) < 1.0:
		# Collision blocked movement → stop dash
		_end_dash()
		return
	
	if _trail_timer <= 0 and trail_scene:
		_trail_timer = trail_spawn_rate
		
		var ghost = trail_scene.instantiate()
		ghost.global_position = _mob.global_position
		var mob_sprite = _mob.get_node_or_null("mob_sprite")
		if mob_sprite:
			ghost.get_node("ghost_sprite").texture = mob_sprite.texture
			ghost.get_node("ghost_sprite").flip_h = mob_sprite.flip_h
			ghost.get_node("ghost_sprite").rotation = mob_sprite.rotation
			ghost.get_node("ghost_sprite").scale = mob_sprite.scale
			ghost.get_node("ghost_sprite").texture_filter =mob_sprite.texture_filter
			ghost.z_index = _mob.z_index - 1
			
		_mob.get_tree().current_scene.add_child(ghost)
		
	_trail_timer -= delta
	
	var move_step = _mob.velocity.length() * delta
	_remaining_distance -= move_step
	
	if _remaining_distance <= 0:
		_end_dash()
	else:
		print(_remaining_distance)
		
		

	
		
func _end_dash():
	_is_dashing = false
	if _mob:
		_mob.velocity = Vector2.ZERO
	if _movement_component:
		_movement_component.set_physics_process(true)
		_movement_component.enabled = true
	
		
