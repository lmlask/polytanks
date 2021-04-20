extends MeshInstance

func _process(delta):
	if owner:
		rotation_degrees.x = -72 + (45 * owner.engine.throttle)
