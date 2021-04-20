extends Area

onready var radioman_camera = owner.get_node("Players/Driver/Camera")
var indicator = "eye"

func interact():
	radioman_camera.togglePortMode(self, 0.3, 74, -0, -30, 30)
