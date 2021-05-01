extends Area

var indicator = "hand"
var state = "closed"

onready var lever = owner.get_node("Interior/TurretInterior/Dynamic/GunRig/Breech/BreechLever")
onready var shape = $CollisionShape
onready var tween = owner.get_node("Interior/Tween")
onready var turretCon = owner.get_node("TurretController")
onready var loader_camera = owner.get_node("Players/Loader/Camera")


func interact():
	if state == "closed" and !loader_camera.holding_shell:
		state == "open"
		tween.interpolate_property(lever, "rotation_degrees:x", lever.rotation_degrees.x, -30, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -30, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
	elif state == "open" and !loader_camera.holding_shell:
		state == "closed"
		tween.interpolate_property(lever, "rotation_degrees:x", lever.rotation_degrees.x, 0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, 0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
