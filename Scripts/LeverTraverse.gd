extends MeshInstance

onready var turretCon = owner.get_node("TurretController")
onready var tween = owner.get_node("Interior/Tween")


func toggle():
	if turretCon.traverse_mode == "power":
		tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(0, 80, 0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(0, 15, 0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
