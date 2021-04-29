extends Spatial

var delay:float = 0.25
var timer:float = 0.0

func _ready():
	pass # Replace with function body.


func _process(delta):
	timer += delta
	if timer > delay and self.current:
		timer -= delay
		R.Map.check_area(global_transform.origin)
