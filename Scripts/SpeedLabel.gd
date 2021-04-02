extends Label

onready var tank = get_parent().get_parent().get_node("PanzerIV")

func _process(delta):
	text = "Speed: " + String(int(tank.speed))
