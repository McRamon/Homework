extends Button


func _ready():
	pressed.connect(on_button_pressed)
	
func on_button_pressed():
	var level = get_parent().get_parent()
	for i in level.alive_enemies:
		print("ENEMY ", i, " IS: ", i.current_state, "
		valid_attack_targets: ", i.valid_attack_targets, "ds
		attack_target: ", i.attack_target )
