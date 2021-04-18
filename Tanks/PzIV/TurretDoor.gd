extends MeshInstance

func move_door(angle_degrees):
	rotate_object_local(Vector3.UP, deg2rad(angle_degrees))
