extends MeshInstance

onready var turret = owner.get_node("Visuals/Turret")

func _process(delta):
	rotation_degrees.y = (turret.rotation_degrees.y * 100)
