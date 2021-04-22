extends MeshInstance

onready var gunControl = owner.get_node("Visuals/Turret/gun")
onready var barrel = owner.get_node("Visuals/Turret/gun/gunMesh/barrel")
var state = "idle"

func _process(delta):
	#Elevation
	rotation.x = gunControl.rotation.x
	
	#Recoil code
#	print(state)
	if state == "back":
		$Breech.translation.z = -0.3
		state = "return"
	elif state == "return":
		if $Breech.translation.z >= 0:
			$Breech.translation.z == 0
			state = "idle"
		else:
			$Breech.translation.z = lerp($Breech.translation.z, 0, delta*3)

func recoil():
	state = "back"
