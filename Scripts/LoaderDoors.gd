extends Area

var state = "closed"
onready var back_door = owner.get_node("Visuals/Turret/TurretDoorLoaderBack")
onready var front_door = owner.get_node("Visuals/Turret/TurretDoorLoaderFront")
onready var shape = $CollisionShape
onready var tween = owner.get_node("Interior/Tween")
onready var lock = owner.get_node("Visuals/Turret/TurretDoorLoaderFront/LoaderDoorLock")
onready var lever_coll = get_parent().get_node("DoorLever/CollisionShape")
onready var slit_coll = get_parent().get_node("LoaderSideport/CollisionShape")

var indicator = "hand"

func interact():
	if get_parent().get_node("DoorLever").state == "closed":
		if state == "closed":
			lock.rotate_object_local(Vector3.UP, deg2rad(-60))
			state = "opening"
		elif state == "open":
			state = "closing"

func _process(delta):
	if state == "opening":
		if back_door.rotation_degrees.y <= -170 and front_door.rotation_degrees.y >= 110:
			state = "open"
			get_parent().get_node("LoaderDoorsToClose/CollisionShape").disabled = false
			lever_coll.disabled = true
			slit_coll.disabled = true
		else:
			back_door.rotate_object_local(Vector3.UP, -5*delta)
			front_door.rotate_object_local(Vector3.UP, 5*delta)
			
	elif state == "closing":
		if back_door.rotation_degrees.y >= -25 and front_door.rotation_degrees.y <= 15:
			back_door.rotation_degrees = Vector3(0, -19.5, -19.9)
			front_door.rotation_degrees = Vector3(0, -19.5, -19.9)
			state = "closed"
			get_parent().get_node("LoaderDoorsToClose/CollisionShape").disabled = true
			lever_coll.disabled = false
			slit_coll.disabled = false
			lock.rotate_object_local(Vector3.UP, deg2rad(60))
		else:
			back_door.rotate_object_local(Vector3.UP, 5*delta)
			front_door.rotate_object_local(Vector3.UP, -5*delta)
			
		
