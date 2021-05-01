extends Area

var indicator = "hand"
var state = "closed"

onready var lever = owner.get_node("Interior/TurretInterior/Dynamic/GunRig/Breech/BreechLever")
onready var shape = $CollisionShape
onready var block = owner.get_node("Interior/TurretInterior/Dynamic/GunRig/Breech/BreechBlock")
onready var tween = owner.get_node("Interior/Tween")
onready var turretCon = owner.get_node("TurretController")
onready var loader_camera = owner.get_node("Players/Loader/Camera")

func interact():
	if state == "closed" and !loader_camera.holding_shell:
		state = "trans"
		tween.interpolate_property(lever, "rotation_degrees:x", lever.rotation_degrees.x, -30, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -30, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(block, "translation:y", block.translation.y, -0.127, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(1), "timeout")
		state = "open"
		turretCon.locked = false
	elif state == "open" and !loader_camera.holding_shell:
		state = "trans"
		tween.interpolate_property(lever, "rotation_degrees:x", lever.rotation_degrees.x, 30, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, 30, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(block, "translation:y", block.translation.y, 0.057, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(1), "timeout")
		state = "closed"
		turretCon.locked = true
