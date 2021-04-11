extends Area

onready var object = get_parent().get_parent().get_node("HullInterior/Dynamic/DriverPanel")
onready var light = get_parent().get_parent().get_node("HullInterior/Dynamic/DriverPanelLight")
var on = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	if on:
		object.set_surface_material(2, load("res://Materials/Toon/Tanks/PanzerIV/interior_darkgrey.tres"))
		light.visible = false
		on = false
	else:
		object.set_surface_material(2, load("res://Materials/Toon/Tanks/PanzerIV/interior_white.tres"))
		light.visible = true
		on = true
		
