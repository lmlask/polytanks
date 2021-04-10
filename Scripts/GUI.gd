extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_compass(b):
	$Compass.transform.basis = b.inverse()
	$Compass/MeshInstance.rotation = Vector3(PI/2,-Vector2.UP.angle_to_point(GameState.wind_vector),0)
