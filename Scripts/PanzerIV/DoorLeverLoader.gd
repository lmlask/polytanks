extends Area

var state = "closed"
onready var lever = owner.get_node("Visuals/Turret/TurretDoorLoaderBack/LeverLoaderDoor")
onready var shape = $CollisionShape
onready var sideport = owner.get_node("Visuals/Turret/TurretDoorLoaderFront/TurretSideslitLoader")
onready var tween = owner.get_node("Interior/Tween")
onready var loader_camera = owner.get_node("Players/Loader/Camera")
var indicator = "hand"


func interact():
	if loader_camera.holding_shell == false and get_parent().get_node("LoaderDoors").state == "closed":
		if state == "closed":
			tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(-60, -90, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(shape, "rotation_degrees", shape.rotation_degrees, Vector3(-80, -109.63, 0.132), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(-0.454, 1.261, -70), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			state = "open"
		elif state == "open":
			tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, -90, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(shape, "rotation_degrees", shape.rotation_degrees, Vector3(-19.904, -109.539, 0.069), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			state = "closed"
	elif get_parent().get_node("LoaderDoors").state == "open":
		get_parent().get_node("LoaderDoors").state = "closing"
