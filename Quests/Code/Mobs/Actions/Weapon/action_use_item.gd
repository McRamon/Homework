extends Action
class_name UseItem

@export var item: Item

func _ready():
	cooldown = item.cooldown
	
func activate(mob: CharacterBody2D, direction: Vector2):
	super(mob, direction)
	if not item:
		return
	item.use(mob, direction)
