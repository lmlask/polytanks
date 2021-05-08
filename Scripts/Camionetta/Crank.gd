extends MeshInstance

onready var parent = get_parent()

func _process(delta):
	rotation.x = parent.rotation.y * 20
