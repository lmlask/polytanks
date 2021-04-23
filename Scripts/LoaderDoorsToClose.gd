extends Area

var indicator = "hand"


func interact():
	if get_parent().get_node("LoaderDoors").state == "open":
		get_parent().get_node("LoaderDoors").state = "closing"
	
