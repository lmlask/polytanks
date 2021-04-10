extends Spatial

var life:float = 5.0
var last_pos
onready var mat = $Particles.process_material
onready var view = $view

func _ready():
	view.hide()
	set_process(false)

func _process(delta):
	if life < 0.0:
		queue_free()
		return
	life -= delta
	
	#Update last_pos
	last_pos = transform.origin
	
	#Movement. To be improved later
	transform.origin += transform.basis.z * delta * 100 #Multiplying by delta to prevent framerate-dependent shell speed
	var dot = Vector2(transform.basis.z.x,transform.basis.z.z).dot(GameState.wind_vector)#.normalized()
	rotate(transform.basis.x, delta/15)
	rotate(transform.basis.y, delta*dot/1000)
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
	


func _on_Area_area_entered(area):
	if life > 0:
		hit(area)
	
func _on_Area_body_entered(body):
	if life > 0:
		hit(body)
	
func hit(target):
	print("hit", target)
	life = -1
