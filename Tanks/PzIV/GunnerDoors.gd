extends Area

var state = "closed"
onready var back_door = owner.get_node("Visuals/Turret/TurretDoorGunnerBack")
onready var front_door = owner.get_node("Visuals/Turret/TurretDoorGunnerFront")
onready var shape = $CollisionShape
onready var tween = owner.get_node("Interior/Tween")


func interact():
	if get_parent().get_node("DoorLever").state == "closed":
		if state == "closed":
			tween.interpolate_property(back_door, "rotation_degrees", back_door.rotation_degrees, Vector3(-13.96, 156.203, -14.331), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.interpolate_property(front_door, "rotation_degrees", front_door.rotation_degrees, Vector3(0, -159.8, -19.903), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			tween.start()
			state = "open"
