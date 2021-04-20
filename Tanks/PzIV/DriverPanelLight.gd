extends Area

onready var object = owner.get_node("Interior/HullInterior/Dynamic/DriverPanel")
onready var light = owner.get_node("Interior/HullInterior/Dynamic/DriverPanelLight")
var on = false
var indicator = "hand"

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
		
