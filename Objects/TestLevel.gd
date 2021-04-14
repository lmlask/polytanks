extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mat:Material = preload("res://Objects/hills map.tres")
var noise = R.NoiseTex.texture.noise
var flat = false
var tile_pos:Vector3 = Vector3.INF

var flats = [Vector3(0,0,0),Vector3(1,0,1),Vector3(1,0,0),Vector3(1,0,2),Vector3(1,0,3)] #define some flat areas

var houses = [Vector3(0,0,0)]

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_pos = (translation/1000).snapped(Vector3(1,10,1))
	for i in flats:
		if tile_pos == i and R.Map.map == 2:
			flat = true
#	var mesh = $MeshInstance.mesh.duplicate()
#	var mat = $MeshInstance.get_surface_material(0) #need a serface material
	
	var mesh = R.Map.mesh25.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = get_noise(Vector2(vertex.x, vertex.z),flat)
#		vertex.y += noise.get_noise_2d((vertex.x+translation.x)/20, (vertex.z+translation.z)/20)*250
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
	
	
	for i in houses:
		var house = R.MHouse.instance()
		R.FloorFinder.find_floor2(house,(i+tile_pos*1000))
		add_child(house)
		house.translation -= translation
		
func get_noise(vec2,flat=false):
	var vec_offset = Vector2(translation.x,translation.z)
	if not flat:
		return noise.get_noise_2dv(vec2+vec_offset)*25
	else:
		var dist:float = vec2.distance_to(Vector2(500,500))
		if  dist > 500:
			return noise.get_noise_2dv(vec2+vec_offset)*25
		elif dist < 350:
			return 0.5
		else:
			return noise.get_noise_2dv(vec2+vec_offset)*25*(dist-350)/150+0.5
