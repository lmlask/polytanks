extends Spatial

var life:float = 2.0

func _ready():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life -= (delta/2)
	transform.origin += transform.basis.z * delta * 100 #Multiplying by delta to prevent framerate-dependent shell speed
	rotate(transform.basis.x, delta/15)
	$shell/Particles.emitting = true
	if life < 0.0:
		queue_free()

