extends ItemWeapon
class_name ItemWeaponRanged

@export var distance:= 500.0
@export var speed:= 1000.0
@export var piercing: bool = false

@export var pellets:= 1
@export var spread:= 0.0

var _direction: Vector2
var _travelled_distance: float = 0.0


func use(mob: CharacterBody2D, direction: Vector2):
	var spread_radians = deg_to_rad(spread)
	for i in range(pellets):
			var angle_offset:= 0.0
			if pellets > 1:
				angle_offset = lerp(-spread_radians / 2, spread_radians / 2, float(i) / float(pellets - 1))
			var pellet_direction = direction.normalized().rotated(angle_offset)
			
			var projectile = weapon_effect.instantiate() as AnimatedSprite2D
			projectile.rotation = pellet_direction.angle() + PI/2
			projectile.global_position = mob.global_position
			mob.get_parent().add_child(projectile)
			projectile.weapon_data = self
			projectile.user = mob
			projectile.direction = pellet_direction.normalized()
			projectile.speed = speed
			projectile.distance = distance
			projectile.damage = damage
			projectile.piercing = piercing
			projectile.force = force
	return true
