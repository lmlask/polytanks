extends RigidBody

func _ready():
	apply_impulse(Vector3(randf(), .1, randf()) - Vector3.ONE * 0.75, -translation.normalized() / 10 + Vector3.UP * 10)
	var material : SpatialMaterial = $MeshInstance.mesh.surface_get_material(0)
	if not material:
		return
	material = material.duplicate()
	$MeshInstance.material_override = material
	material.flags_transparent = true
	
	$Tween.interpolate_property(material, "albedo_color", Color.white, Color(1, 1, 1, 0), 2, Tween.TRANS_EXPO, Tween.EASE_OUT, 4)
	$Tween.start()
