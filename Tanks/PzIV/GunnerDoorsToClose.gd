extends Area

func interact():
	if get_parent().get_node("GunnerDoors").state == "open":
		get_parent().get_node("GunnerDoors").state = "closing"
	
