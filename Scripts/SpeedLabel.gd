extends Label

#onready var tank = get_parent().get_parent().get_node("PanzerIV")
#onready var tank = get_parent().vehicle

func _process(delta):
	text = "Speed: " + String(int(owner.vehicle.speed))
