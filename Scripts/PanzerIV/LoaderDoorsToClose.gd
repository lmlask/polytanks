extends Area

var indicator = "hand"
onready var loader_camera = owner.get_node("Players/Loader/Camera")


func interact():
	if loader_camera.holding_shell == false and get_parent().get_node("LoaderDoors").state == "open":
		get_parent().get_node("LoaderDoors").state = "closing"
	
