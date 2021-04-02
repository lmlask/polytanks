extends Label

#onready var tank = get_parent().get_parent().get_node("PanzerIV")
onready var tank = get_parent().vehicle

func _process(_delta):
	text = "Engine: " + tank.engine.state
