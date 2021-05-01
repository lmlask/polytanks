extends Area

onready var driver_camera = owner.get_node("Players/Driver/Camera")
var indicator = "eye"

func interact():
	if driver_camera.mode == "pan":
		driver_camera.togglePortMode(self, 0.3, 74, -0, -19, 19)
	else:
		driver_camera.resetCamera(76)
