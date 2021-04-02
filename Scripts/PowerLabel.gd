extends Label

onready var tank = get_parent().get_parent().get_node("PanzerIV")

func _process(_delta):
	text = "Engine power output: " + String(int(tank.engine.enginePower))
