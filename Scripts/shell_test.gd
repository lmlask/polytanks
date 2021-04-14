extends Spatial

var life:float = 30.0
#onready var view = $view
onready var Explosion = preload("res://Scenes/Explosion.tscn")
onready var models = [$Model/HEModel, $Model/APCModel, $Model/APCRModel, $Model/HEATModel]
var host = false
remote var xform = null
var timer:float = 0.0
var shell_speed = 600

func _ready():
	pass
#	view.hide()
#	set_process(false)

remotesync func explode(pos):
	var explo = Explosion.instance()
	explo.global_transform.origin = pos
	get_parent().add_child(explo) #owner of shell should say where the explosion is
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
	
	
	#Spin shell model
	for i in models:
		if i.visible:
			i.rotation_degrees.y += 5

	#Tracer
	$Tracer.visible = (timer > 0.01)
	
	#Despawn
	if $RayCast.is_colliding():
		var col = $RayCast.get_collider()
		if col:
			col = col.owner
			if col:
				if col.has_method("hit"):
					print("hit")
					col.hit(self)
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
	
func hit(target):
	print("noooo")
	life = -1
