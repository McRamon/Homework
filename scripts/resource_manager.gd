# res://Scripts/ResourceManager.gd
extends Node

# словарь ресурсов: String → int
var resources := {
	"wood": 100,
	"stone": 50,
	"food": 30
}

signal resource_changed(type, amount)

func add_resource(type: String, amount: int) -> void:
	resources[type] = resources.get(type, 0) + amount
	emit_signal("resource_changed", type, resources[type])

# Проверяет, хватает ли по всем позициям
func can_afford(cost: Dictionary) -> bool:
	for t in cost.keys():
		if resources.get(t, 0) < cost[t]:
			return false
	return true

# Списывает ресурсы (предполагаем, что перед этим вызван can_afford)
func spend(cost: Dictionary) -> void:
	for t in cost.keys():
		resources[t] = resources.get(t, 0) - cost[t]
		emit_signal("resource_changed", t, resources[t])
