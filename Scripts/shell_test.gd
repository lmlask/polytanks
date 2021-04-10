extends Spatial

var life:float = 4.0
var last_pos
onready var mat = $Particles.process_material

func _ready():
	set_process(false)

func _process(delta):
	#Lifetime
	life -= delta
	
	#Update last_pos
	last_pos = transform.origin
	
	#Movement. To be improved later
	transform.origin += transform.basis.z * delta * 100 #Multiplying by delta to prevent framerate-dependent shell speed
	rotate(transform.basis.x, delta/15)
#	transform.origin += Vector3(GameState.wind_vector.x,0,GameState.wind_vector.y)/100
	
	#Particle emission extents
	#Put particle box halfway between the last shell position and the current one
	$Particles.global_transform.origin = ((last_pos + global_transform.origin)/2)
	#Set box boundaries to be from curr pos to last pos
	var dist = global_transform.origin.distance_to(last_pos)
	#for some reason the dist is too small? multiplying it by 10 makes good trails, so be it
	mat.emission_box_extents = Vector3(1, dist*10, 1)
	
	#Despawn
	if life < 0.0:
		queue_free()
