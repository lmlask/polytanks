extends "res://Scripts/FPCamera.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_parent().get_parent().get_parent().get_node("Interior/HullInterior/DriverClickables").get_children():
		interact_areas.append(i)
