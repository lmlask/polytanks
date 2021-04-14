extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mat:Material = preload("res://Objects/hills map.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
#	var mesh = $MeshInstance.mesh.duplicate()
#	var mat = $MeshInstance.get_surface_material(0) #need a serface material
	var noise = R.NoiseTexture.texture.noise
	
	var mesh = R.Map.mesh25.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	print(mdt.get_vertex(mdt.get_face_vertex(1,0)))
	print(mdt.get_vertex(mdt.get_face_vertex(1,1)))
	print(mdt.get_vertex(mdt.get_face_vertex(1,2)))
	
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x+translation.x, vertex.z+translation.z)*25
		vertex.y += noise.get_noise_2d((vertex.x+translation.x)/10, (vertex.z+translation.z)/10)*250
		mdt.set_vertex(i, vertex)

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

	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	$MeshInstance/StaticBody/CollisionShape.shape = mesh.create_trimesh_shape()
	$MeshInstance.mesh = mesh
	$MeshInstance.set_surface_material(0, mat)
