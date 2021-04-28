extends Spatial

var max_speed = 20
var auto = true
var life:float = 60
onready var truck = $MeshInstance
onready var DownRay = $RayCast
onready var LeftR = $MeshInstance/Left
onready var RightR = $MeshInstance/Right
var timer:float = 0
var delay:float = 1
var turn_rate:float = 0
var target_turn_rate:float = 0

func _ready():
	translation = Vector3(rand_range(-1000,100),0,rand_range(-1000,1000))
	R.FloorFinder.find_floor2(self)
	truck.rotation.y = randf()*TAU

func _process(delta):
	if translation.y < -1000:
		queue_free()
	timer +=delta
	turn_rate = lerp(turn_rate, target_turn_rate, 0.05)
	if timer > delay:
		timer -= delay
		delay = rand_range(2,5)
		target_turn_rate = rand_range(-PI/3, PI/3)
	truck.rotation.y += turn_rate * delta
	life -= delta
	if life < 0.0:
		queue_free()
	var speed = max_speed-(abs(turn_rate)*5)
	translation += truck.transform.basis.x * delta * speed
	if LeftR.is_colliding():
		target_turn_rate = -PI
		delay = 0.333
		timer = 0
	elif RightR.is_colliding():
		target_turn_rate = PI
		delay = 0.333
		timer = 0
	if DownRay.is_colliding():
		translation.y = lerp(DownRay.get_collision_point().y,translation.y,0.95)
		var tfs = Transform.looking_at(DownRay.get_collision_normal(),Vector3.RIGHT)
		tfs = tfs.rotated(tfs.basis.x,-PI/2)
		transform.basis = tfs.basis.slerp(transform.basis,0.95)
