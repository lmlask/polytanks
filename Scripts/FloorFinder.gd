extends Spatial

onready var ray = $RayCast

func _ready():
	pass # Replace with function body.

func find_floor(tank, pos = Vector3.ZERO):
	ray.enabled = true
	if pos == Vector3.ZERO:
		ray.translation = Vector3(rand_range(-50,50),500,rand_range(-50,50))
	else:
		ray.translation = pos + Vector3(0,500,0)
#	ray.translation = Vector3(rand_range(-54,-54),500,rand_range(83,83))
	ray.force_raycast_update()
	if ray.is_colliding():
#		print("Ray")
#		print(ray.get_collision_point())
#		print(ray.get_collision_normal())
		var tsf = Transform.looking_at(ray.get_collision_normal(),Vector3(1,0,0))
		tsf = tsf.rotated(tsf.basis.x,-PI/2)
		tsf = tsf.rotated(tsf.basis.y,randf()*TAU)
		tsf.origin = ray.get_collision_point()
		set_xform(tank,tsf)

func set_xform(tank,tsf):
	tsf.origin += tsf.basis.y/2
	tank.transform = tsf
	for tankrays in tank.rayElements:
		tankrays.force_raycast_update()
		if tankrays.is_colliding():
			set_xform(tank,tsf)
#	return tsf
#		return [ray.get_collision_point(),ray.get_collision_normal()]
		
