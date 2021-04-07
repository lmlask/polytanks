extends RigidBody

func _ready():
	apply_impulse(Vector3(randf(), .1, randf()) - Vector3.ONE * 0.75, -translation.normalized() / 10 + Vector3.UP * 10)
	$Tween.interpolate_property($MeshInstance, "scale", scale, scale * .6, randf() * 4, Tween.TRANS_LINEAR, Tween.EASE_IN, 4)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
