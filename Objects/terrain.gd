extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mat:Material = preload("res://Objects/hills map.tres")
var noise = R.NoiseTex.texture.noise
var flat = false
var tile_pos:Vector3 = Vector3.INF

#var height = true #heightmap
#var flats = [Vector3(0,0,0),Vector3(1,0,1),Vector3(1,0,0),Vector3(1,0,2),Vector3(1,0,3)] #define some flat areas

#var alphagrepmap = "res://Textures/greyalpha-16bit.exr"
#var flatmap = "res://Textures/flat.exr"
var height_map = {0:["res://Textures/greyalpha-16bit.exr","Test map"],
	1:["res://Textures/flat.exr","Flat map"],
	2:["res://Textures/likethis.exr","Like this map"]}
var height_factor = 200

var image = Image.new()
var imgdata

#building key in array locations
#all this needs to be in a file selectable by the map
var site1 = {R.MHouse:[Vector3(10,0,0),],
	R.VWKWagen:[Vector3(10,0,5),Vector3(0,0,5),Vector3(-10,0,5)],
	R.BerHouseS1:[Vector3(30,0,0)],
	R.BerHouseT2:[Vector3(10,0,20),Vector3(-40,0,10)],
	R.BerHouseT4:[Vector3(-20,0,-20)],
	R.BerHouseT3:[Vector3(10,0,-20),Vector3(20,0,-20),Vector3(-10,0,-20),Vector3(10,0,40)]}

#location of towns global locations
var site_locations = {Vector3(50,0,0):site1,Vector3(200,0,200):site1,Vector3(250,0,-2500):site1,Vector3(750,0,300):site1,Vector3(550,0,-200):site1}
var site_added = []

#var height_map = {Vector3(-1,0,0):alphagrepmap,Vector3(-1,0,-1):polytankmap} #Should be one image for the entire map

var mutex = Mutex.new()
var inprogress = false
# Called when the node enters the scene tree for the first time.

func _ready():
	if height_map:
		image.load(height_map[R.Map.map][0]) 
		imgdata = image.get_data()
#	var imageTex = ImageTexture.new()
#	imageTex.create_from_image(image,0)

func add_tile(tile_pos,mesh): 
	var tile = $Tile.duplicate()
	tile.translation = (tile_pos)*1000-Vector3(500,0,500)
	var tile_mesh = create_tile_mesh(tile,tile_pos,mesh)
	tile_mesh.surface_set_material(0, mat)
	mutex.lock()
	tile.mesh = tile_mesh
	inprogress = true
	tile.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	inprogress = false
	mutex.unlock()
	add_child(tile)
	tile.show()
	return tile

func update_tile(tile_pos,mesh,tile_node):
	var tile_mesh = create_tile_mesh(tile_node,tile_pos,mesh)
	tile_mesh.surface_set_material(0, mat)
	mutex.lock()
	tile_node.mesh = tile_mesh
	while inprogress:
		yield(get_tree().create_timer(1),"timeout")
	tile_node.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	mutex.unlock()
	
func create_tile_mesh(tile, tile_pos,meshx):
#	tile_pos = (tile.translation/1000).snapped(Vector3(1,10,1))
#	for i in flats:
#		if tile_pos == i and R.Map.map == 2:
#			flat = true
#	var mesh = $MeshInstance.mesh.duplicate()
#	var mat = $MeshInstance.get_surface_material(0) #need a serface material
		
	var mesh = meshx.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
#		if i < 3:
#			print(vertex)
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
	yield(get_tree(),"idle_frame")
	for pos in site_locations:
		if not site_added.has(tile_pos):
			if (pos/1000).snapped(Vector3(1,10,1)) == tile_pos:
				for building in site_locations[pos]:
					for bpos in site_locations[pos][building]:
						add_buildings(pos,building,bpos)
	site_added.append(tile_pos)
		

func add_buildings(pos, Buidling, bpos):
	var building = Buidling.instance()
	var grid = (pos/1000).snapped(Vector3(1,10,1))
#	print("add building at ",grid)
	R.Map.maptiles[grid].add_child(building)
	building.translation = pos+bpos+Vector3(500,0,500)-grid*1000
	R.FloorFinder.find_floor2(building,true)
	

func get_noise(tile, vec2):
	var vec_offset = Vector2(tile.translation.x,tile.translation.z)
	var n = noise.get_noise_2dv(vec2+vec_offset)/10.0+0.05
	vec2 = (vec2+vec_offset)/R.Map.fine_size+Vector2(1024,1024)
	vec2 = Vector2(clamp(vec2.x,0,2048),clamp(vec2.y,0,2048))
	image.lock()
	var col = image.get_pixelv(vec2)
	image.unlock()
	n = n*(1-col.a)+col.r*col.a
#		print(n,"-",col.r,"-",col.a)
	n *= 1.75
	return n*n*height_factor