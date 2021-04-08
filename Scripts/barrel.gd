extends MeshInstance

var state = "idle"

func _ready():
	pass

func _process(delta):
	if state == "back":
		translation.z = 1.884
		state = "return"
	elif state == "return":
		if translation.z >= 2.286:
			translation.z == 2.286
			state = "idle"
		else:
			translation.z = lerp(translation.z, 2.3, delta*3)

func recoil():
	if state == "idle":
		state = "back"
