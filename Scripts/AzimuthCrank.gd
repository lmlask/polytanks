extends MeshInstance

onready var turret = owner.get_node("Visuals/Turret")

func _process(_delta):
	rotation_degrees.y = (turret.rotation_degrees.y * 100)
