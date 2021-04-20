extends Area

onready var gunner_light = owner.get_node("Interior/TurretInterior/Dynamic/LightGunner")
onready var loader_light = owner.get_node("Interior/TurretInterior/Dynamic/LightLoader")
onready var switch = owner.get_node("Interior/TurretInterior/Dynamic/SwitchTurretLight")

var indicator = "hand"

func interact():
	if gunner_light.visible:
		gunner_light.visible = false
		loader_light.visible = false
		switch.rotation_degrees.z = 26
	else:
		gunner_light.visible = true
		loader_light.visible = true
		switch.rotation_degrees.z = -34
	
