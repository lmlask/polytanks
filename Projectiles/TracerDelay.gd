extends MeshInstance

var timer:float = 0.0

func _process(delta):
	timer += delta
	if timer > 0.015:
		show()
		set_process(false)
