extends Area

var state = "closed"
onready var lever = get_parent().get_parent().get_node("HullInterior/Dynamic/LeverDriver")
onready var shape = $CollisionShape
onready var sideport = get_parent().get_parent().get_parent().get_node("Visuals/Hull/HullSideportDriver")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func interact():
	if state == "closed":
		state = "opening"
	elif state == "open":
		state = "closing"
	
	
func _process(delta):
	if state == "opening":
		if lever.rotation_degrees.z >= 59.9:
			lever.rotation_degrees.z = 60
			shape.rotation_degrees.z = 60
			sideport.rotation_degrees.z = 75
			state = "open"
		else:
			lever.rotation_degrees.z = lerp(lever.rotation_degrees.z, 60, delta*6)
			shape.rotation_degrees.z = lerp(shape.rotation_degrees.z, 60, delta*6)
			sideport.rotation_degrees.z = lerp(sideport.rotation_degrees.z, 75, delta*6)
	elif state == "closing":
		if lever.rotation_degrees.z <= 0.01:
			lever.rotation_degrees.z = 0
			shape.rotation_degrees.z = 0
			sideport.rotation_degrees.z = 0
			state = "closed"
		else:
			lever.rotation_degrees.z = lerp(lever.rotation_degrees.z, 0, delta*6)
			shape.rotation_degrees.z = lerp(shape.rotation_degrees.z, 0, delta*6)
			sideport.rotation_degrees.z = lerp(sideport.rotation_degrees.z, 0, delta*6)
