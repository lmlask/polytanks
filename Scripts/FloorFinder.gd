extends Spatial
class_name FF

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
		var tbz = tank.transform.basis.z
		var tbx = tank.transform.basis.x
		var tsf = Transform.looking_at(ray.get_collision_normal(),Vector3(1,0,0))#.rotated(Basis.IDENTITY.z,PI/2)
		tsf = tsf.rotated(tsf.basis.x,-PI/2)
		tsf.basis.z = tbz
		tsf.basis.x = tbx
		if tank.auto:
			tsf = tsf.rotated(tsf.basis.y,randf()*TAU)
#		else:
#			tsf = tsf.rotated(tsf.basis.y,-PI/2)
		tsf.origin = ray.get_collision_point()
		set_xform(tank,tsf)

func find_floor2(building, rot = true):
	ray.translation = building.global_transform.origin + Vector3(0,500,0)
	ray.force_raycast_update()
	if ray.is_colliding():
		var tsf = Transform.looking_at(ray.get_collision_normal(),Vector3(1,0,0))
		tsf = tsf.rotated(tsf.basis.x,-PI/2)
		if rot:
			tsf = tsf.rotated(tsf.basis.y,randf()*TAU)
		building.transform.basis = tsf.basis
		building.transform.origin.y = ray.get_collision_point().y
		building.scale *= 2 #Should not need to double the size
#		var grid = (building.owner.transform.origin/1000).snapped(Vector3(1,10,1))
#		building.translation += Vector3(500,0,500)-grid*1000



func set_xform(tank,tsf):
#	tsf.origin += tsf.basis.y/5
	tank.transform = tsf
	tank.next_transform(tsf)
	for tankrays in tank.rayElements:
		tankrays.force_raycast_update()
		while tankrays.is_colliding():
			tsf.origin += tsf.basis.y/5
			tank.transform = tsf
			tankrays.force_raycast_update()
#	tank.transform = tsf
	
#	return tsf
#		return [ray.get_collision_point(),ray.get_collision_normal()]
		
