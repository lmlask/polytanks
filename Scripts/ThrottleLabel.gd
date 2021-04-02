extends Label

onready var tank = get_parent().get_parent().get_node("PanzerIV")

func _process(_delta):
	text = "Throttle: " + String(int(100*tank.engine.throttle)) + "%"
