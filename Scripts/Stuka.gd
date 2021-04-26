extends Spatial

var life = 99.0

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life -= delta
	if life < 0:
		queue_free()
	translation += transform.basis.z * delta * 100
