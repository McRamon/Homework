extends Resource
class_name Item

@export var name: String = "Item"
@export var description: String = "This should not appear"
@export var spritesheet: SpriteFrames
#Каждый предмет(Item) в игре имеет соответствующий png файл со всеми необходимыми спрайтами,
#кадрами анимаций и прочего. Когда некая механика в игре (например инвентарь) 
#будет использовать ресурс предмета, она будет делать это следующим образом:
#func _ready():
	#icon.sprite_frames = item.spritesheet
	#icon.play(item.icon_anim)
#В данном коде icon - это AnimatedSprite2D, отвечающая за иконку предмета, item - 
#это ресурс предмета. Соответственно SpriteFrames файл, привязанный к ресурсу предмета,
#по определенному шаблону должен быть нарезан на анимации(если это 1 кадр, без анимации, 
#все равно он создан как анимация). play(item.icon_anim) - в зависимости от необходимости,
#например play.(item.ui_icon) для инвентаря

@export var flags: Array = []
@export var stackable: bool = false
@export var max_amount: int = 1

@export var usable:bool = false 
@export var cooldown: float #Откат использования если предмет можно использовать (например оружие)

func _init():
	if stackable == false:
		max_amount = 1
	
func get_animation(icon_type: String) -> String:
	var anim_name = name.to_lower().replace(" ", "_") + "_" + icon_type + "_icon"
	if spritesheet and spritesheet.has_animation(anim_name):
		return anim_name
	elif spritesheet.has_animation(name.to_lower().replace(" ", "_") + "_icon"):
		return name.to_lower().replace(" ", "_") + "_icon"
	elif spritesheet.has_animation("default_icon"):
		return "default_icon"
	else:
		return ""
		
#item.get_animation(ui), например в случае если мы ищем спрайт предмета Красные Ботинки -
# - name = Red Boots, то вызов item.get_animation(ui) даст нам red_boots_ui_icon

func has_flag(flag: String) -> bool:
	return flag in flags
	
func use(mob: CharacterBody2D, direction: Vector2):
	pass
	
func on_pick_up():
	pass
	
	
