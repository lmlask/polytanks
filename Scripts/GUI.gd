extends Spatial

func set_compass(b):
	visible = GameState.WindView #Fix me only needs to be set once
	var s = GameState.wind_vector.length()/100
	$Compass/MeshInstance.scale =  Vector3(s,s,s)
	$Compass.transform.basis = b.inverse()
	$Compass/MeshInstance.rotation = Vector3(PI/2,-Vector2.UP.angle_to_point(GameState.wind_vector),0)
	
