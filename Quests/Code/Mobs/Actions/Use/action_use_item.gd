extends Action
class_name UseItem

@export var item: Item

func _ready():
	if item:
		cooldown = item.cooldown
	
func activate(mob: CharacterBody2D, direction: Vector2):
	if !super(mob, direction):
		return
	if not item:
		return
	item.use(mob, direction)
