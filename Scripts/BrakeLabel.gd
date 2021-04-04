extends Label

#onready var tank = get_parent().get_parent().get_node("PanzerIV")
#onready var tank = get_parent().vehicle

func _process(_delta):
	text = "Brake: " + String(int(100*owner.vehicle.engine.brake)) + "%"
