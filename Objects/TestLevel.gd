extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh = $MeshInstance.mesh.duplicate()
	var mat = $MeshInstance.get_surface_material(0)
	print(mat)
	var noise = R.NoiseTexture.texture.noise

	# Configure
#	noise.seed = randi()
#	noise.octaves = 4
#	noise.period = 20.0
#	noise.persistence = 0.8

	# Sample
		
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x+translation.x, vertex.z+translation.z)*25
		mdt.set_vertex(i, vertex)
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	$MeshInstance/StaticBody/CollisionShape.shape = mesh.create_trimesh_shape()
	$MeshInstance.mesh = mesh
	$MeshInstance.set_surface_material(0, mat)
