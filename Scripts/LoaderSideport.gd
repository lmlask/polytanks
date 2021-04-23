extends Area

onready var loader_camera = owner.get_node("Players/Loader/Camera")
var indicator = "eye"

func interact():
	if get_parent().get_node("LoaderDoors").state == "closed":
		if loader_camera.mode == "pan":
			loader_camera.togglePortMode(self, 0.3, -110, -0, -30, 30)
		else:
			loader_camera.resetCamera(-130)
	elif get_parent().get_node("LoaderDoors").state == "open":
		get_parent().get_node("LoaderDoors").state = "closing"
