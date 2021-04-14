extends Spatial

var delay:float = 0.1
var timer:float = 0.0

func _ready():
	pass # Replace with function body.


func _process(delta):
	timer += delta
	if timer > delay:
		timer -= delay
		R.Map.check_area(global_transform.origin,true)
