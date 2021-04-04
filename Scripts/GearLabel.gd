extends Label

#onready var tank = get_parent().get_parent().get_node("PanzerIV")
#onready var tank = get_parent().vehicle

func _process(_delta):
	if owner.vehicle.engine.clutch == 0:
		text = "Gear: " + String(int(owner.vehicle.engine.gear))
	else:
		text = "Gear: " + String(int(owner.vehicle.engine.gear)) + "      CLUTCH"
	
	
