extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mat:Material = preload("res://Objects/hills map.tres")
var noise = R.NoiseTex.texture.noise
var flat = false
var tile_pos:Vector3 = Vector3.INF
var height_factor = 25
var height = false #heightmap
#var flats = [Vector3(0,0,0),Vector3(1,0,1),Vector3(1,0,0),Vector3(1,0,2),Vector3(1,0,3)] #define some flat areas

var alphagrepmap = "res://Textures/greyalpha.png"
var polytankmap = "res://Textures/polytank.png"
var image = Image.new()
var imgdata
#building key in array locations
var site1 = {R.MHouse:[Vector3(10,0,0), Vector3(30,0,0),Vector3(10,0,20),Vector3(-10,0,10),Vector3(-20,0,-20),Vector3(10,0,-20)]}

#location of towns global locations
var site_locations = {Vector3(0,0,0):site1,Vector3(100,0,0):site1,Vector3(250,0,0):site1,Vector3(750,0,0):site1,Vector3(1000,0,0):site1}
var site_added = []

#var height_map = {Vector3(0,0,0):alphagrepmap,Vector3(1,0,1):polytankmap}
var height_map = {}

var mutex = Mutex.new()
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
	
#	var imageTex = ImageTexture.new()
#	imageTex.create_from_image(image,0)

func add_tile(tile_pos,mesh):
	var tile = $Tile.duplicate()
	tile.translation = (tile_pos)*1000-Vector3(500,0,500)
	var tile_mesh = create_tile_mesh(tile,tile_pos,mesh)
	mutex.lock()
	tile.mesh = tile_mesh
	tile.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	tile.mesh.surface_set_material(0, mat)
	mutex.unlock()
	add_child(tile)
	tile.show()
	return tile

func update_tile(tile_pos,mesh,tile_node):
	var tile_mesh = create_tile_mesh(tile_node,tile_pos,mesh)
	mutex.lock()
	tile_mesh.surface_set_material(0, mat)
	tile_node.mesh = tile_mesh
	tile_node.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	mutex.unlock()
	
func create_tile_mesh(tile, tile_pos,meshx):
#	tile_pos = (tile.translation/1000).snapped(Vector3(1,10,1))
#	for i in flats:
#		if tile_pos == i and R.Map.map == 2:
#			flat = true
#	var mesh = $MeshInstance.mesh.duplicate()
#	var mat = $MeshInstance.get_surface_material(0) #need a serface material
	height = false
	if height_map.has(tile_pos):
		image.load(height_map[tile_pos])
		imgdata = image.get_data()
		height = true
		
	var mesh = meshx.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y = get_noise(tile, Vector2(vertex.x, vertex.z))
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
	return mesh

#should be called on check that map is loaded for site
func add_sites(tile_pos):
	for pos in site_locations:
		if not site_added.has(tile_pos):
			if (pos/1000).snapped(Vector3(1,10,1)) == tile_pos:
				for building in site_locations[pos]:
					for bpos in site_locations[pos][building]:
						add_buildings(pos,building,bpos)
	site_added.append(tile_pos)
		

func add_buildings(pos, Buidling, bpos):
	var building = Buidling.instance()
	R.FloorFinder.find_floor2(building,pos+bpos,false)
	var grid = (pos/1000).snapped(Vector3(1,10,1))
	R.Map.maptiles[grid].add_child(building)
	building.translation += Vector3(500,0,500)-grid*1000
	building.scale *= 2

func get_noise(tile, vec2,flat=false):
	var vec_offset = Vector2(tile.translation.x,tile.translation.z)
	var n = noise.get_noise_2dv(vec2+vec_offset)
	if height:
		image.lock()
		var col = image.get_pixelv(vec2)
		n = n*(1-col.a)+col.r*col.a
		print(n,"-",col.r,"-",col.a)
	return n*height_factor
