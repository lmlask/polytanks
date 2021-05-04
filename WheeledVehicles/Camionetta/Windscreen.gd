extends Area

var indicator = "hand"
onready var windscreen = owner.get_node("Visuals/Windscreen")
onready var tween = owner.get_node("Interior/Tween")
onready var shape = $CollisionShape
var state = "up"

func interact():
	if state == "up":
		state = "down"
		tween.interpolate_property(windscreen, "rotation_degrees:x", windscreen.rotation_degrees.x, -10, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -10, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.start()
	else:
		state = "up"
		tween.interpolate_property(windscreen, "rotation_degrees:x", windscreen.rotation_degrees.x, -120, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -120, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
