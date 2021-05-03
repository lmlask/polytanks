extends MeshInstance

func _process(delta):
	self.rotation.z = owner.get_node("RaysWheels/FL_ray").rotation.y * 5
