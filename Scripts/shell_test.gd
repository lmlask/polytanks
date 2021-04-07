extends MeshInstance

var life:float = 2.0

func _ready():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life -= delta
	transform.origin += transform.basis.z
	rotate(transform.basis.x, delta/15)
	if life < 0.0:
		queue_free()

