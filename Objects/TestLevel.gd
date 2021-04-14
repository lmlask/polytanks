extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh = $MeshInstance.mesh.duplicate()
	var mat = $MeshInstance.get_surface_material(0)
#	print(mat)
	var noise = R.NoiseTexture.texture.noise

	# Configure
#	noise.seed = randi()
#	noise.octaves = 4
#	noise.period = 20.0
#	noise.persistence = 0.8

	# Sample
		
	var mdt = MeshDataTool.new()
#	var mat2 = mdt.get_material()
	mdt.create_from_surface(mesh, 0)
	print(mdt.get_vertex(6538))
	print(mdt.get_vertex_normal(6538))
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x+translation.x, vertex.z+translation.z)*25
		mdt.set_vertex(i, vertex)
#		mdt.set_vertex_normal(i,vertex)


	for i in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		# Calculate face normal.
		var n = (bp - cp).cross(ap - bp).normalized()
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))

	# Run through vertices one last time to normalize normals and
	# set color to normal.
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
#		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))
#		mdt.set_vertex_color(i, Color(1,1,1))


	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
#	mdt.set_material(mat)
	$MeshInstance/StaticBody/CollisionShape.shape = mesh.create_trimesh_shape()
	$MeshInstance.mesh = mesh
	$MeshInstance.set_surface_material(0, mat)
