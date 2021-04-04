extends Label

#onready var tank = get_parent().get_parent().get_node("PanzerIV")
#onready var tank = owner.vehicle

func _process(_delta):
	text = "Engine: " + owner.vehicle.engine.state
