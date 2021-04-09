extends Spatial

var intact = true
var col
var alpha = -0.5
var material:SpatialMaterial

func _ready():
	set_process(false)

func _on_Area_area_entered(area):
	if area.is_in_group("shell") and intact:
		intact = false
		$Cube/Destruction.destroy()
		$Smoke.emitting = true
		$Pieces.emitting = true
		$Cube/Area.queue_free()
		$Cube/StaticBody.queue_free()
		material = $house_rubble.mesh.surface_get_material(0)
		material.albedo_color.a = 0.0
		col = material.albedo_color
		$house_rubble.visible = true
		$house_rubble/StaticBody/CollisionShape.disabled = false
		set_process(true)

func _process(delta):
	if alpha > 0.0:
		col.a = alpha
		material.albedo_color = col
	alpha += delta / 5
	if alpha > 1.0:
		set_process(false)
