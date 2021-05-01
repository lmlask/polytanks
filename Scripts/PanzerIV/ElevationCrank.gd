extends MeshInstance

onready var turret = owner.get_node("Visuals/Turret")

func _process(_delta):
	rotation_degrees.x = turret.get_node("gun").rotation_degrees.x * -250
