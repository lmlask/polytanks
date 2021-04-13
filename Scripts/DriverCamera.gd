extends "res://Scripts/FPCamera.gd"

onready var tween = get_parent().get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_parent().get_parent().get_parent().get_node("Interior/DriverClickables").get_children():
		interact_areas.append(i)
		

func tween(pos, speed, easing):
	tween.interpolate_property(self, "translation", translation, pos, speed, easing, Tween.EASE_IN_OUT)
	tween.start()
	true_offset = Vector2(0, 0)
