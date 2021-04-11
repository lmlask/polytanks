extends Area

var state = "closed"
onready var hatch = get_parent().get_parent().get_parent().get_node("Visuals/Hull/DriverHatch")

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
		if hatch.rotation_degrees.x >= 178.9:
			hatch.rotation_degrees.x = 179
			state = "open"
		else:
			hatch.rotation_degrees.x = lerp(hatch.rotation_degrees.x, 179, delta*4)
	elif state == "closing":
		if hatch.rotation_degrees.x <= 0.01:
			hatch.rotation_degrees.x = 0
			state = "closed"
		else:
			hatch.rotation_degrees.x = lerp(hatch.rotation_degrees.x, 0, delta*4)
