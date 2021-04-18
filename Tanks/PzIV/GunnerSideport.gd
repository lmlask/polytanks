extends Area

onready var gunner_camera = owner.get_node("Players/Gunner/Camera")

func interact():
	if get_parent().get_node("GunnerDoors").state == "closed":
		gunner_camera.togglePortMode(self, 0.3, 110, -0, -30, 30)
