extends Node
class_name ActionControl

@export var user: CharacterBody2D

@export var weapon: ItemWeapon
@export var potion: ItemPotion
@export var ability: Ability

var weapon_cooldown: float = 0.0
var potion_cooldown: float = 0.0
var ability_cooldown: float = 0.0

var _weapon_on_cooldown: bool = false
var _potion_on_cooldown: bool = false
var _ability_on_cooldown: bool = false

var use_direction: Vector2


func use_weapon(direction: Vector2):
	if _weapon_on_cooldown:
		return
	if !weapon:
		return
	if weapon.attack_type == CombatDefines.AttackType.MELEE:
		use_direction = direction
		var effect = weapon.weapon_effect.instantiate() as AnimatedSprite2D
		effect.rotation = direction.angle() + PI / 2
		effect.direction = direction
		user.add_child(effect)
		effect.weapon_data = weapon
		effect.position = Vector2.ZERO
		effect.user = user
		effect.mob_hit.connect(_on_mob_hit)
	elif weapon.attack_type == CombatDefines.AttackType.RANGED:
		var spread_radians = deg_to_rad(weapon.spread)
		for i in range(weapon.pellets):
				var angle_offset:= 0.0
				if weapon.pellets > 1:
					angle_offset = lerp(-spread_radians / 2, spread_radians / 2, float(i) / float(weapon.pellets - 1))
				var pellet_direction = direction.normalized().rotated(angle_offset)
				
				var projectile = weapon.weapon_effect.instantiate() as AnimatedSprite2D
				projectile.rotation = pellet_direction.angle() + PI/2
				projectile.global_position = owner.global_position
				owner.get_parent().add_child(projectile)
				projectile.weapon_data = weapon
				projectile.user = owner
				projectile.direction = pellet_direction.normalized()
				projectile.speed = weapon.speed
				projectile.distance = weapon.distance
				projectile.piercing = weapon.piercing
				projectile.mob_hit.connect(_on_mob_hit)
	_start_weapon_cooldown()
	
func _on_mob_hit(body: CharacterBody2D):
	if body and body.health_component:
		body.health_component.take_damage(weapon.damage, weapon.attack_type)
	if weapon.status_effects and body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("apply_status_effect"):
		for i in weapon.status_effects:
			body.get_node("HealthComponent").apply_status_effect(i)
	if body.has_node("AnimationComponent"):
		#var direction = user.global_position.direction_to(body.global_position)
		body.animation_component.push(use_direction, weapon.force)
		print(body, " is pushed in the direction ", use_direction, " with force: ", weapon.force)

	
func _start_weapon_cooldown():
	_weapon_on_cooldown = true
	get_tree().create_timer(weapon_cooldown).timeout.connect(_reset_weapon_cooldown)
	
func _reset_weapon_cooldown():
	_weapon_on_cooldown = false
	
func _start_potion_cooldown():
	_weapon_on_cooldown = true
	get_tree().create_timer(potion_cooldown).timeout.connect(_reset_potion_cooldown)
	
func _reset_potion_cooldown():
	_potion_on_cooldown = false
	
func _start_ability_cooldown():
	_ability_on_cooldown = true
	get_tree().create_timer(ability_cooldown).timeout.connect(_reset_ability_cooldown)
	
func _reset_ability_cooldown():
	_ability_on_cooldown = false
	
	
	
#extends Node
#class_name Action
#
#var action_user: CharacterBody2D
#
#var cooldown: float = 0.0
#var _on_cooldown:= false
#
#func can_activate() -> bool:
	#return not _on_cooldown
#
#func activate(user: CharacterBody2D, direction: Vector2):
	#action_user = user
	#if _on_cooldown:
		#return false
	#_start_cooldown()
	#print("Super activate function activated")
	#return true
	#
#func _start_cooldown():
	#_on_cooldown = true
	#get_tree().create_timer(cooldown).timeout.connect(_reset_cooldown)
	#print("attack is on cooldown")
	#
#func _reset_cooldown():
	#_on_cooldown = false
	#print("weapon is ready")
	#
#func _on_mob_hit(body: CharacterBody2D, damage, type):
	#pass

#func _ready():
	#if item:
		#cooldown = item.cooldown
	#
#func activate(user: CharacterBody2D, direction: Vector2):
	#if !super(user, direction):
		#return
	#if not item:
		#return
	#use_direction = direction
	#item.use(user, direction, self)
	#
#func _on_mob_hit(body: CharacterBody2D, damage, type):
	#if body and body.health_component:
		#body.health_component.take_damage(damage, type)
	#if item.status_effects and body.has_node("HealthComponent") and body.get_node("HealthComponent").has_method("apply_status_effect"):
		#for i in item.status_effects:
			#body.get_node("HealthComponent").apply_status_effect(i)
	#if body.has_node("AnimationComponent"):
		##var direction = user.global_position.direction_to(body.global_position)
		#body.animation_component.push(use_direction, item.force)
		#print(body, " is pushed in the direction ", use_direction, " with force: ", item.force)
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
#func activate(mob: CharacterBody2D, direction: Vector2):
	#if not mob:
		#return
	#_mob = mob
	#print(_mob, " starts dashing")
	#
	#_movement_component = _mob.get_node_or_null("MovementComponent")
	#if not _movement_component:
		#push_warning("DashAbility: No MovementComponent found on mob")
	#_is_dashing = true
	#_dash_direction = direction
	#_remaining_distance = dash_distance
	#_movement_component.set_physics_process(false)
	#_movement_component.enabled = false
	#_movement_component.direction = Vector2.ZERO
	#_mob.velocity = direction * dash_speed
	#print("dash velocity set to: ", _mob.velocity)
	#print("dash activated by ", mob)
	##
	##
#func _physics_process(delta: float) -> void:
	#if not _is_dashing:
		#return
	#
	#var old_position = _mob.global_position
	#_mob.velocity = _dash_direction * dash_speed * delta
	#_mob.move_and_collide(_mob.velocity)
	#
	#if _mob.global_position.distance_to(old_position) < 1.0:
		## Collision blocked movement → stop dash
		#_end_dash()
		#return
	#
	#if _trail_timer <= 0 and trail_scene:
		#_trail_timer = trail_spawn_rate
		#
		#var ghost = trail_scene.instantiate()
		#ghost.global_position = _mob.global_position
		#var mob_sprite = _mob.get_node_or_null("mob_sprite")
		#if mob_sprite:
			#ghost.get_node("ghost_sprite").texture = mob_sprite.texture
			#ghost.get_node("ghost_sprite").flip_h = mob_sprite.flip_h
			#ghost.get_node("ghost_sprite").rotation = mob_sprite.rotation
			#ghost.get_node("ghost_sprite").scale = mob_sprite.scale
			#ghost.get_node("ghost_sprite").texture_filter =mob_sprite.texture_filter
			#ghost.z_index = _mob.z_index - 1
			#
		#_mob.get_tree().current_scene.add_child(ghost)
		#
	#_trail_timer -= delta
	#
	#var move_step = _mob.velocity.length()
	#_remaining_distance -= move_step
	#
	#if _remaining_distance <= 0:
		#_end_dash()
	#else:
		#print(_remaining_distance)
		#
		#
#
	#
		#
#func _end_dash():
	#_is_dashing = false
	#if _mob:
		#_mob.velocity = Vector2.ZERO
	#if _movement_component:
		#_movement_component.set_physics_process(true)
		#_movement_component.enabled = true
