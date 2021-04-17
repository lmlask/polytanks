extends MeshInstance

onready var gunControl = owner.get_node("Visuals/Turret/gun")

func _process(delta):
	rotation.x = gunControl.rotation.x
