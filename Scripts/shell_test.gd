extends MeshInstance

var free = false

func _ready():
	set_process(false)
	if free:
		yield(get_tree().create_timer(1), "timeout")
		queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform.origin += transform.basis.z
