extends Area

var state = "closed"
onready var lever = owner.get_node("Visuals/Turret/TurretDoorGunnerBack/LeverGunnerDoor")
onready var shape = $CollisionShape
onready var sideport = owner.get_node("Visuals/Turret/TurretDoorGunnerFront/TurretSideslitGunner")
onready var tween = owner.get_node("Interior/Tween")


func interact():
	if get_parent().get_node("GunnerDoors").state == "closed":
		if state == "closed":
			tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, 0, 60), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(0, 0, 70), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			state = "open"
		elif state == "open":
			tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			state = "closed"
	elif get_parent().get_node("GunnerDoors").state == "open":
		get_parent().get_node("GunnerDoors").state = "closing"
