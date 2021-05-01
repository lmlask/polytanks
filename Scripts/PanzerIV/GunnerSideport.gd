extends Area

onready var gunner_camera = owner.get_node("Players/Gunner/Camera")
var indicator = "eye"

func interact():
	if get_parent().get_node("GunnerDoors").state == "closed":
		if gunner_camera.mode == "pan":
			gunner_camera.togglePortMode(self, 0.3, 110, -0, -30, 30)
		else:
			gunner_camera.resetCamera(96)
	elif get_parent().get_node("GunnerDoors").state == "open":
		get_parent().get_node("GunnerDoors").state = "closing"
