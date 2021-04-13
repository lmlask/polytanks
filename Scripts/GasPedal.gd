extends MeshInstance

func _process(delta):
	if owner:
		rotation_degrees.x = 35 * owner.engine.throttle
