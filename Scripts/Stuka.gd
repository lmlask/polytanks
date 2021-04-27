extends Spatial

var life:float = 60
onready var FwdRay = $MeshInstance/FwdRay
onready var DownRay = $DownRay
onready var plane = $MeshInstance
var agl_prev = 0.0
var timer = 0.0
var delay = 1.0
var target_bank = 0

func _ready():
	plane.rotation.y = randf()*TAU
	plane.rotation.z = rand_range(-PI/3, PI/3)

func _process(delta):
	if translation.y < -1000:
		queue_free()
	timer +=delta
	if timer > delay:
		timer -= delay
		delay = rand_range(2,5)
		target_bank = rand_range(-PI/3, PI/3)
	plane.rotation.z = lerp(plane.rotation.z,target_bank, delta/2)	
	plane.rotation.y -= plane.rotation.z/150
	life -= delta
	if life < 0:
		queue_free()
	translation += plane.transform.basis.z * delta * 100
	if FwdRay.is_colliding():
		plane.rotation.x -= delta / 2
	elif DownRay.is_colliding():
		var agl = translation.y - DownRay.get_collision_point().y
		if agl < agl_prev:
			plane.rotation.x -= delta / (agl/10)
		agl_prev = agl
	else:
		plane.rotation.x += delta / 2
	plane.rotation.x = clamp(plane.rotation.x, -PI/2, PI/4)
