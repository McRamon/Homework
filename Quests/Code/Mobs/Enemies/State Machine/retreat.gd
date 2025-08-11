extends Node
class_name RetreatState

const MobDefines = preload("res://Code/Defines/mob_defines.gd")

var is_retreating := false
var timer_timing:= false

func run(mob: CharacterBody2D, navigator: NavigationAgent2D):
	var found := false
	var tries := 0
	var map_rid = navigator.get_navigation_map()
	
	if !navigator.is_navigation_finished() and is_retreating:
		return
	if timer_timing:
		return
	
	while not found and tries < 10:
		var random_angle = randf_range(0.0, TAU)
		var escape_direction = Vector2.RIGHT.rotated(random_angle).normalized()
		var distance = randf_range(mob.chase_range, mob.chase_range + 200)
		var candidate_position = mob.global_position + escape_direction * distance
		
		var closest_point = NavigationServer2D.map_get_closest_point(map_rid, candidate_position)
		
		if candidate_position.distance_to(closest_point) < 400:
			navigator.target_position = closest_point
			found = true
			print("MOB ", mob, " is escaping to: ", closest_point)
			is_retreating = true
			timer_timing = true
			get_parent().start_timer(randf_range(5.0, 15.0), self, "_on_timer_timeout")
		else:
			tries += 1
			
	if not found:
		print(" MOB ", mob, " tried to escape, but could not")
		
func _on_timer_timeout():
	timer_timing = false
		
