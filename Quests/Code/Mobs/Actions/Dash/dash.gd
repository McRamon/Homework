#extends Node
#
#@export var dash_speed: float = 1200.0
#@export var dash_distance: float = 300.0
#
#var dash_direction: Vector2 = Vector2.ZERO
#var dashing: bool = false
#var dash_target_position: Vector2
#var mob: CharacterBody2D = null
#
#func _ready():
	#set_physics_process(true)
#
#func activate(mob_instance: CharacterBody2D, direction: Vector2) -> void:
	#if dashing:
		#return
	#if mob_instance == null:
		#push_warning("start_dash called with null mob")
		#return
	#mob = mob_instance
	#dash_direction = direction.normalized()
	#if dash_direction == Vector2.ZERO:
		#return
#
	#var space_state = mob.get_world_2d().direct_space_state
	#var from_pos = mob.global_position
	#var to_pos = from_pos + dash_direction * dash_distance
#
	#var query = PhysicsRayQueryParameters2D.new()
	#query.from = from_pos
	#query.to = to_pos
	#query.exclude = [mob]
#
	#var result = space_state.intersect_ray(query)
#
	#if result:
		#dash_target_position = result.position - dash_direction * 4.0
	#else:
		#dash_target_position = to_pos
#
	#dashing = true
	#print("Dash started for mob at ", from_pos, " towards ", dash_target_position)
#
#func _physics_process(delta: float) -> void:
	#if dashing and mob != null:
		#var step = dash_speed * delta
		#var motion = dash_direction * step
		#var collision = mob.move_and_collide(motion)
		#if collision:
			#dashing = false
			#mob = null
			#print("Dash stopped by collision")
		#else:
			## Check if reached target manually (if needed)
			#var distance_to_target = (dash_target_position - mob.global_position).length()
			#if distance_to_target <= step:
				#dashing = false
				#mob.global_position = dash_target_position
				#mob = null
				#print("Dash ended normally")



#extends Action
#class_name DashAbility
#
#@export var dash_distance: float = 300.0
#@export var dash_speed: float = 1500.0
#
#@export var trail_scene: PackedScene
#@export var trail_spawn_rate := 0.05
#
#var _mob: CharacterBody2D
#var _movement_component: Node
#var _is_dashing := false
#var _dash_direction := Vector2.ZERO
#var _remaining_distance: float = 0.0
#var _trail_timer := 0.0
#
#
#func activate(mob: CharacterBody2D, direction: Vector2) -> void:
	#if not mob:
		#push_warning("DashAbility: No mob provided")
		#return
	#if direction == Vector2.ZERO:
		#push_warning("DashAbility: No dash direction provided")
		#return
#
	#_mob = mob
	#_dash_direction = direction.normalized()
	#_remaining_distance = dash_distance
	#_is_dashing = true
#
	## --- Disable MovementComponent immediately ---
	#_movement_component = _mob.get_node_or_null("MovementComponent")
	#if _movement_component:
		#_movement_component.set_physics_process(false)
		#_movement_component.enabled = false
#
	## --- Kill all residual velocity and motion ---
	#_mob.velocity = Vector2.ZERO
	#_mob.move_and_collide(Vector2.ZERO)
#
	## --- Start dash on next physics frame (clean state) ---
	#call_deferred("_start_dash")
#
#
#func _start_dash():
	#if not is_instance_valid(_mob):
		#return
	#_mob.velocity = _dash_direction * dash_speed
	#print("DashAbility: Dash started clean with velocity:", _mob.velocity)
#
#
## ======================
##   PHYSICS PROCESS
## ======================
#func _physics_process(delta: float) -> void:
	#if not _is_dashing or not is_instance_valid(_mob):
		#return
#
	#var old_position = _mob.global_position
#
	## Move mob
	#_mob.velocity = _dash_direction * dash_speed
	#_mob.move_and_slide()
#
	## Collision check (stopped movement)
	#if _mob.global_position.distance_to(old_position) < 0.5:
		#print("DashAbility: Dash interrupted by collision")
		#_end_dash()
		#return
#
	## Spawn trail effect
	#_spawn_trail(delta)
#
	## Update remaining dash distance
	#_remaining_distance -= dash_speed * delta
	#if _remaining_distance <= 0:
		#_end_dash()
#
#
## ======================
##   DASH TRAIL SPAWN
## ======================
#func _spawn_trail(delta: float):
	#_trail_timer -= delta
	#if _trail_timer <= 0.0 and trail_scene:
		#_trail_timer = trail_spawn_rate
#
		#var ghost = trail_scene.instantiate()
		#ghost.global_position = _mob.global_position
#
		#var mob_sprite = _mob.get_node_or_null("mob_sprite")
		#if mob_sprite and ghost.has_node("ghost_sprite"):
			#var gs = ghost.get_node("ghost_sprite")
			#if gs is Sprite2D and mob_sprite is Sprite2D:
				#gs.texture = mob_sprite.texture
				#gs.flip_h = mob_sprite.flip_h
				#gs.rotation = mob_sprite.rotation
				#gs.scale = mob_sprite.scale
				#gs.texture_filter = mob_sprite.texture_filter
				#ghost.z_index = _mob.z_index - 1
#
		#_mob.get_tree().current_scene.add_child(ghost)
#
#
## ======================
##   END DASH
## ======================
#func _end_dash():
	#_is_dashing = false
#
	#if is_instance_valid(_mob):
		#_mob.velocity = Vector2.ZERO
#
	#if is_instance_valid(_movement_component):
		#_movement_component.set_physics_process(true)
		#_movement_component.enabled = true
#
	#print("DashAbility: Dash ended for", _mob.name)


#var _trail_timer := 0.0
#
#var _movement_component: Node
#var _remaining_distance: float
#var _is_dashing:= false
#var _dash_direction:= Vector2.ZERO
#
#var _mob: CharacterBody2D
extends Action
class_name DashAction

@export var dash_distance: float = 300.0
@export var dash_speed: float = 1500.0

@export var trail_scene: PackedScene
@export var trail_spawn_rate := 0.05

var _mob: CharacterBody2D
var _movement_component: Node
var _is_dashing := false
var _dash_direction := Vector2.ZERO
var _remaining_distance: float = 0.0
var _trail_timer := 0.0

func activate(mob: CharacterBody2D, direction: Vector2):
	if not mob:
		return
	_mob = mob
	print(_mob, " starts dashing")
	
	_movement_component = _mob.get_node_or_null("MovementComponent")
	if not _movement_component:
		push_warning("DashAbility: No MovementComponent found on mob")
	_is_dashing = true
	_dash_direction = direction
	_remaining_distance = dash_distance
	_movement_component.set_physics_process(false)
	_movement_component.enabled = false
	_movement_component.direction = Vector2.ZERO
	_mob.velocity = direction * dash_speed
	print("dash velocity set to: ", _mob.velocity)
	print("dash activated by ", mob)
	#
	#
func _physics_process(delta: float) -> void:
	if not _is_dashing:
		return
	
	var old_position = _mob.global_position
	_mob.velocity = _dash_direction * dash_speed * delta
	_mob.move_and_collide(_mob.velocity)
	
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
	
		
