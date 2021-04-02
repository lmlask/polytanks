extends Label

onready var tank = get_parent().get_parent().get_node("PanzerIV")

func _process(_delta):
	if tank.engine.clutch == 0:
		text = "Gear: " + String(int(tank.engine.gear))
	else:
		text = "Gear: " + String(int(tank.engine.gear)) + "      CLUTCH"
	
	
