extends MeshInstance

onready var mat

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = get_surface_material(0)
	
func _process(delta):
	var target_offset = (-0.5) + (rad2deg(owner.get_global_transform().basis.get_euler().y)/360)
	mat.uv1_offset.x = target_offset
