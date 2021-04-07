extends Spatial

var intact = true

func _on_Area_area_entered(area):
	if area.is_in_group("shell") and intact:
		intact = false
		$Cube/Destruction.destroy()
