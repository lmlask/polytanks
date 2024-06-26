extends Spatial

var life:float = 30.0
#onready var view = $view

onready var models = [$Model/HEModel, $Model/APCModel, $Model/APCRModel, $Model/HEATModel]
var host = false
remote var xform = null
var timer:float = 0.0
export var shell_speed = 600
var type:int

func _ready():
	if host:
		print("Firing:",GameState.Ammo.keys()[type])
#	view.hide()
#	set_process(false)

remotesync func explode(pos):
	var explo = R.Explosion.instance()
	get_parent().add_child(explo) #owner of shell should say where the explosion is
	explo.global_transform.origin = pos #!!!! Indicating an error here
	call_deferred("queue_free")

func _physics_process(delta):
	if (life < 0.0 or translation.y < -100) and host:
		rpc("explode", transform.origin)
		return
	
	if host:
		life -= delta
		timer += delta
		transform.origin += transform.basis.z * delta * shell_speed
		var dot = Vector2(transform.basis.z.x,transform.basis.z.z).dot(GameState.wind_vector)#.normalized()
		rotate(transform.basis.x, delta/25)
		rotate(transform.basis.y, delta*dot/1000)
#		if GameState.ShellCam:
#			$view/Viewport/Camera.global_transform = global_transform
#			$view/Viewport/Camera.rotate(transform.basis.y, PI)
#			$view/Viewport/Camera.transform.origin -= transform.basis.z/4
#			$view/Viewport/Camera.transform.origin += transform.basis.y/5
		if timer > 0.1:
			rset_unreliable("xform", transform)
			timer -= 0.1

	elif not xform == null:
		transform = xform
		xform.origin += transform.basis.z * delta * shell_speed
	else:
		transform.origin += transform.basis.z * delta * shell_speed
	#Multiplying by delta to prevent framerate-dependent shell speed
#	print(Vector2(transform.basis.z.x,transform.basis.z.z).dot(GameState.wind_vector.normalized()))
#	transform.origin += Vector3(GameState.wind_vector.x,0,GameState.wind_vector.y)/100
	if not host:
		return
	
	#Spin shell model
	for i in models:
		if i.visible:
			i.rotation_degrees.y += 5

	#Tracer
#	$Tracer.visible = (timer > 0.01)
	
	#Despawn
	if $RayCast.is_colliding():
		var col = $RayCast.get_collider()
		if col:
			if col.has_method("hit"):
				print("Projectile hit something")
#					col.hit(self,type, $RayCast.get_collider())
				var angle = transform.basis.z.dot($RayCast.get_collision_normal())
				var nm = col.get_network_master()
				col.rpc_id(nm, "hit", type, angle, $RayCast.get_collider_shape())
				transform.origin = $RayCast.get_collision_point()
		life = -1

func shellcam(i):
	$view.visible = i
	$view/Viewport/Camera.visible = i
	$RemoteTransform.update_position = i
	$RemoteTransform.update_rotation = i
	

func _on_Area_area_entered(area):
	if life > 0:
		hit(area)
	
func _on_Area_body_entered(body):
	if life > 0:
		hit(body)
	
func hit(_target):
	print("hmmm")
	life = -1
