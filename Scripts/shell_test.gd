extends Spatial

var life:float = 30.0
var last_pos
onready var mat = $Particles.process_material
onready var view = $view
onready var Explosion = preload("res://Scenes/Explosion.tscn")
var host = false
remote var xform = null
var timer:float = 0.0
var shell_speed = 750

func _ready():
	view.hide()
	set_process(false)

remotesync func explode(pos):
	var explo = Explosion.instance()
	explo.global_transform.origin = pos
	get_parent().add_child(explo) #owner of shell should say where the explosion is
	call_deferred("queue_free")

func _process(delta):
	if life < 0.0 or translation.y < -100 and host:
		rpc("explode", transform.origin)
		return
	#Update last_pos
	last_pos = transform.origin
	
	#Movement. To be improved later
	if host:
		life -= delta
		timer += delta
		transform.origin += transform.basis.z * delta * shell_speed #Multiplying by delta to prevent framerate-dependent shell speed
		var dot = Vector2(transform.basis.z.x,transform.basis.z.z).dot(GameState.wind_vector)#.normalized()
		rotate(transform.basis.x, delta/25)
		rotate(transform.basis.y, delta*dot/1000)
		if timer > 0.1:
			rset_unreliable("xform", transform)
			timer -= 0.1
	elif not xform == null:
		transform = xform
		xform.origin += transform.basis.z * delta * shell_speed
	#Multiplying by delta to prevent framerate-dependent shell speed
	
#	print(Vector2(transform.basis.z.x,transform.basis.z.z).dot(GameState.wind_vector.normalized()))
#	transform.origin += Vector3(GameState.wind_vector.x,0,GameState.wind_vector.y)/100
	
	#Particle emission extents
	#Put particle box halfway between the last shell position and the current one
	$Particles.global_transform.origin = ((last_pos + global_transform.origin)/2)
	#Set box boundaries to be from curr pos to last pos
	var dist = global_transform.origin.distance_to(last_pos)
	#for some reason the dist is too small? multiplying it by 10 makes good trails, so be it
	mat.emission_box_extents = Vector3(1, dist*10, 1)
	$view/Viewport/Camera.global_transform = global_transform
	$view/Viewport/Camera.rotate(transform.basis.y, PI)
	$view/Viewport/Camera.transform.origin -= transform.basis.z/5
	$view/Viewport/Camera.transform.origin += transform.basis.y/5
	
	#Despawn
	if $RayCast.is_colliding():
		var col = $RayCast.get_collider()
		if not col == null:
			col = col.owner
			if not col == null:
				if col.has_method("hit"):
					print("hit")
					col.hit(self)
			life = -1


func _on_Area_area_entered(area):
	if life > 0:
		hit(area)
	
func _on_Area_body_entered(body):
	if life > 0:
		hit(body)
	
func hit(target):
	print("noooo")
	life = -1
