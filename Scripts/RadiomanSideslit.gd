extends Area

onready var radioman_camera = owner.get_node("Players/Radioman/Camera")
var indicator = "eye"

func interact():
	if radioman_camera.mode == "pan":
		radioman_camera.togglePortMode(self, 0.3, -76, -0, -30, 30)
	else:
		radioman_camera.resetCamera(-64)
