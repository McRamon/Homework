extends Node

#extends Node
#class_name DamageDash
#
#@export var damage: int = 10
#
#var _damaged_bodies := []
#
#func activate(mob, direction) -> void:
	#super(mob, direction)
	#
	#_damaged_bodies.clear()
	#var detector = _mob.get_node_or_null("detection_area")
	#if detector:
		#if detector.body_entered.is_connected(_on_body_entered):
			#detector.body_entered.disconnect(_on_body_entered) 
		#detector.body_entered.connect(_on_body_entered)
#
#func _on_body_entered(body: CharacterBody2D):
	#if body == _mob or body in _damaged_bodies:
		#return
	#if body.get_node("HealthComponent").has_method("take_damage"):
		#body.get_node("HealthComponent").take_damage(damage)
		#_damaged_bodies.append(body)
		#print("Damaged ", body, " with", self)
		#
#func _end_dash():
	#super()
	#var detector = _mob.get_node_or_null("detection_area")
	#if detector.body_entered.is_connected(_on_body_entered):
			#detector.body_entered.disconnect(_on_body_entered) 
		#








#func on_dash_start(player, movement_component):
	#movement_component.velocity = movement_component.input_direction.normalized() * dash_speed
	#
	#var detection_area = player.get_node("detection_area")
	#if detection_area and not _connected:
		#detection_area.body_entered.connect(_on_body_entered.bind(player))
		#_connected = true
#
#func on_dash_end(player, movement_component):
	#var detection_area = player.get_node("detection_area")
	#if detection_area and _connected:
		#detection_area.body_entered.disconnect(_on_body_entered)
		#_connected = false
			#
#func _on_body_entered(body, player):
	#if body.is_in_group("Enemies") and "take_damage" in body:
		#body.take_damage(damage)
