extends MeshInstance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if owner:
		rotation_degrees.x = -35 * owner.engine.brake
