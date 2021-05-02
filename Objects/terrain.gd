extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var mat:Material = preload("res://Objects/hills map.tres")
var noise = R.NoiseTex.texture.noise
var flat = false
var terrainMeshsC = [] #Center
var terrainMeshs0 = [] #Edge 
var terrainMeshs1 = [] #Edge
var terrainMeshs2 = [] #Edge
var terrainMeshs3 = [] #Edge
var level = 7
var prev_level = -1
var direction = 0
var prev_dir = 0
signal terrain_completed


var timer:float = 0.0
var tile_offset = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1)]
#var tile_pos:Vector3 = Vector3.INF #Does not seem to be needed

#var height = true #heightmap
#var flats = [Vector3(0,0,0),Vector3(1,0,1),Vector3(1,0,0),Vector3(1,0,2),Vector3(1,0,3)] #define some flat areas

#var alphagrepmap = "res://Textures/greyalpha-16bit.exr"
#var flatmap = "res://Textures/flat.exr"

var height_factor = 200


var img_loaded = false
#var imgdata

#building key in array locations
#all this needs to be in a file selectable by the map
#var site1 = {R.MHouse:[Vector3(10,0,0),],
#	R.VWKWagen:[Vector3(10,0,5),Vector3(0,0,5),Vector3(-10,0,5)],
#	R.BerHouseS1:[Vector3(30,0,0)],
#	R.BerHouseT2:[Vector3(10,0,20),Vector3(-40,0,10)],
#	R.BerHouseT4:[Vector3(-20,0,-20)],
#	R.BerHouseT3:[Vector3(10,0,-20),Vector3(20,0,-20),Vector3(-10,0,-20),Vector3(10,0,40)]}

#location of towns global locations
#var site_locations = {Vector3(50,0,0):site1,Vector3(200,0,200):site1,Vector3(250,0,-2500):site1,Vector3(750,0,300):site1,Vector3(550,0,-200):site1}
var site_locations = {}
var site_added = []

#var height_map = {Vector3(-1,0,0):alphagrepmap,Vector3(-1,0,-1):polytankmap} #Should be one image for the entire map

var mutex = Mutex.new()
var inprogress = false
# Called when the node enters the scene tree for the first time.

func _ready():
	$Tile.material_override = $Tile.material_override.duplicate()
	set_paint()
	
func set_paint():
	$Tile.material_override.set_shader_param("paint",R.Paint.tex)
	var offset:Vector2 = Vector2(translation.x,translation.z)/4.5+Vector2(1024,1024)
#	offset = Vector2(clamp(offset.x,0,2048),clamp(offset.y,0,2048))/2048
	$Tile.material_override.set_shader_param("offset",offset/2048)

func set_pos(grid):
	translation = (grid)*1024-Vector3(512,0,512)

func update_tile(grid):
	if grid == R.pos2grid(translation):
#		print("Center, do nothing")
		level = 0
		direction = 0
		return
	var rel_grid = R.pos2grid(translation)-grid
	if abs(rel_grid.x) == abs(rel_grid.z):
		level = floor((abs(rel_grid.x))/2)
		direction = 0
		return
	if rel_grid.z < 0 and abs(rel_grid.x) <= abs(rel_grid.z): #Left
		level = floor((abs(rel_grid.z)-1)/2)
		if int(abs(rel_grid.z)-1)%2 == 1:
			direction = 3
		else:
			direction = 0
		return
	if rel_grid.x > 0 and abs(rel_grid.z) <= abs(rel_grid.x): #UP
		level = floor((abs(rel_grid.x)-1)/2)
		if int(abs(rel_grid.x)-1)%2 == 1:
			direction = 4
		else:
			direction = 0
		return
	if rel_grid.z > 0 and abs(rel_grid.x) <= abs(rel_grid.z): #Right
		level = floor((abs(rel_grid.z)-1)/2)
		if int(abs(rel_grid.z)-1)%2 == 1:
			direction = 1
		else:
			direction = 0
		return
	if rel_grid.x < 0 and abs(rel_grid.z) <= abs(rel_grid.x): #UP
		level = floor((abs(rel_grid.x)-1)/2)
		if int(abs(rel_grid.x)-1)%2 == 1:
			direction = 2
		else:
			direction = 0
		return

func _process(delta):
	timer += delta
	if timer > 1.0:
		timer = 0.0
#		var grid = R.pos2grid(translation)
#		if grid == R.pos2grid(GameState.view_location):
#			for i in range(1,5):
#				if R.Map.terrainNodes.has(grid+tile_offset[i]):
#					R.Map.terrainNodes[grid+tile_offset[i]].level = level
#					R.Map.terrainNodes[grid+tile_offset[i]].direction = i
#		if not direction == 0:
#			if R.Map.terrainNodes.has(grid+tile_offset[direction]) and not direction == 0:
#				R.Map.terrainNodes[grid+tile_offset[direction]].direction = direction
#				R.Map.terrainNodes[grid+tile_offset[direction]].level = level-1
		level = clamp(level,0,R.Map.terrainMeshs[0].size()-1)
		if not prev_level == level or not prev_dir == direction:
			prev_level = level
			prev_dir = direction
			var mesh = create_tile_mesh(self,R.Map.terrainMeshs[direction][level])
			$Tile.mesh = mesh
			$Tile/StaticBody/CollisionShape.shape = mesh.create_trimesh_shape()
			emit_signal("terrain_completed", R.pos2grid(translation))
#			print("terain complete.")
			
			
#func load_image(map):
#	if height_map and not R.Map.map == -1:
#		image = load(height_map[map][0]).get_data()
#		image.lock()
#		img_loaded = true
#		imgdata = image.get_data()
#	var imageTex = ImageTexture.new()
#	imageTex.create_from_image(image,0)

func add_tile(tile_pos,mesh): 
	var tile = $Tile.duplicate()
	tile.translation = (tile_pos)*1024-Vector3(512,0,512)
	var tile_mesh = create_tile_mesh(tile,mesh)
#	tile_mesh.surface_set_material(0, mat)
	mutex.lock()
	tile.mesh = tile_mesh
	inprogress = true
	tile.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	inprogress = false
	add_child(tile)
	mutex.unlock()
	tile.show()
	return tile

func update_tile2(mesh,tile_node): #old
	var tile_mesh = create_tile_mesh(tile_node,mesh)
#	tile_mesh.surface_set_material(0, mat)
	mutex.lock()
	tile_node.mesh = tile_mesh
	tile_node.set_aabb()
	if not inprogress:
		tile_node.get_node("StaticBody/CollisionShape").shape = tile_mesh.create_trimesh_shape()
	else:
		print_debug("this should not happen, means the shape hasnt been updated")
	mutex.unlock()
	
func create_tile_mesh(tile, meshx):
		
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
		vertex.y = get_noise(tile, Vector2(vertex.x, vertex.z))
#		vertex.y += noise.get_noise_2d((vertex.x+translation.x)/20, (vertex.z+translation.z)/20)*250
		mdt.set_vertex(i, vertex)
		
#	mesh.surface_remove(0)
#	mdt.commit_to_surface(mesh)
#	var st = SurfaceTool.new()
#	st.create_from(mesh,0)
#	st.generate_normals()
#	st.generate_tangents()
#	mesh.surface_remove(0)
#	st.commit(mesh)
#	mesh.regen_normalmaps()
#	return mesh

	for i in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
#		var ap = mdt.get_vertex(a)
#		var bp = mdt.get_vertex(b)
#		var cp = mdt.get_vertex(c)
		# Calculate face normal.
#		var n = (bp - cp).cross(ap - bp).normalized()
		var n = mdt.get_face_normal(i)
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
		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))
	
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
#	var st = SurfaceTool.new()
#	st.create_from(mesh,0)
#	st.generate_normals()
#	var mesh2 = ArrayMesh.new()
#	mesh.surface_remove(0)
#	st.commit(mesh)
#	mesh.regen_normalmaps()
	return mesh
	mdt.create_from_surface(mesh, 0)
	print(mdt.get_face_count())
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
		var n = (bp - cp).cross(ap - bp).normalized()*0
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
#		mdt.set_vertex_normal(a, n + mdt.get_face_normal(i))
#		mdt.set_vertex_normal(b, n + mdt.get_face_normal(i))
#		mdt.set_vertex_normal(c, n + mdt.get_face_normal(i))
#		if i == 7:
#			print("fn2 ",mdt.get_vertex_normal(a))

	# Run through vertices one last time to normalize normals and
	# set color to normal.
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
		if i == 7:
			print("fn2 ",mdt.get_vertex_normal(i))
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	return mesh

#should be called on check that map is loaded for site
func add_sites(tile_pos):
	yield(get_tree(),"idle_frame")
	for pos in site_locations:
		if not site_added.has(tile_pos):
			if (pos/1024).snapped(Vector3(1,10,1)) == tile_pos:
				for building in site_locations[pos]:
					for bpos in site_locations[pos][building]:
						add_buildings(pos,building,bpos)
	site_added.append(tile_pos)
		

func add_buildings(pos, Buidling, bpos):
	var building = Buidling.instance()
	var grid = (pos/1024).snapped(Vector3(1,1024,1))
#	print("add building at ",grid)
	R.Map.maptiles[grid].add_child(building)
	building.translation = pos+bpos+Vector3(512,0,512)-grid*1024
	R.FloorFinder.find_floor2(building,true)
	

func get_noise(tile, vec2):
	var vec_offset = Vector2(tile.translation.x,tile.translation.z)
	var n = noise.get_noise_2dv(vec2+vec_offset)/5.0+0.05
	vec2 = (vec2+vec_offset)/R.Map.map_size+Vector2(1024,1024)
	vec2 = Vector2(clamp(vec2.x,0,2047),clamp(vec2.y,0,2047))
#	image.lock()
	if not R.Map.map == -1:
		var col = R.heightMap.get_pixelv(vec2)
		n = n*(1-col.a)+col.r*col.a
	else:
		n *= 3
#	image.unlock()
		
#		print(n,"-",col.r,"-",col.a)
	n *= 1.75
	return n*n*height_factor
