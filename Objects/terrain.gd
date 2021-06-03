extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var mat:Material = preload("res://Objects/hills map.tres")
var noise = R.NoiseTex.texture.noise
var flatareas = []
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
#onready var FlatG = $FlatGeometry
onready var EnvItems = $EnvItems

var timer:float = 0.0
var tile_offset = [Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1)]

var height_factor = 200

var img_loaded = false

var site_locations = {}
var site_added = []

var mutex = Mutex.new()
var inprogress = false
# Called when the node enters the scene tree for the first time.

#Threading
var semaphore:Semaphore
var thread:Thread
var loop_thread = true


# The thread will start here.

func _ready():
	$Tile.material_override = $Tile.material_override.duplicate()
	set_paint()
	R.Editor.connect("editor_state", self, "editor")
	semaphore = Semaphore.new()
	thread = Thread.new()
	connect("terrain_completed", self, "terrain_complete", [], CONNECT_DEFERRED)
	R.Paint.connect("reload_area", self, "reload_area")
	

func editor(data):
	return
#	print("From editor", data)
#	FlatG.visible = data
#	for j in $ControlNodes.get_children():
#		j.visible = data
	
func set_paint():
	$Tile.material_override.set_shader_param("paint",R.Paint.tex)
	var offset:Vector2 = Vector2(translation.x,translation.z)/4.5+Vector2(1024,1024)
#	offset = Vector2(clamp(offset.x,0,2048),clamp(offset.y,0,2048))/2048
	$Tile.material_override.set_shader_param("offset",offset/2048)

func set_pos(grid):
	translation = (grid)*1024-Vector3(512,0,512)

func update_tile(grid):
	if grid == R.pos2grid(translation):
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

func reload_area():
	print("reloading area")
	prev_level = -1

func _process(delta):
#	print(flatareas)
	timer += delta
	if timer > 1.0:
		timer = 0.0
		level = clamp(level,0,R.Map.terrainMeshs[0].size()-1)
		if not prev_level == level or not prev_dir == direction and not thread.is_active():
			R.thread_count += 1
			if R.thread_count > R.max_threads:
				R.thread_count -= 1
			else:
				prev_level = level
				prev_dir = direction
				thread.start(self, "_thread_loop", [], Thread.PRIORITY_LOW)
	#			print("terain complete.")

func check_thread_count():
	if thread.is_active():
		R.thread_check += 1

func _thread_loop(_data):
#	print("thread start", translation)
#	while loop_thread:
#		semaphore.wait()
#	print("thread continue")
	var mesh = create_tile_mesh(R.Map.terrainMeshs[direction][level])
	processs_all_areas(mesh) #should generate normal after this step not before
#	fix_border(R.pos2grid(translation))
	gen_normals(mesh)
#	$Tile.mesh = mesh
#	$Tile/StaticBody/CollisionShape.shape = mesh.create_trimesh_shape()
	var shape = mesh.create_trimesh_shape()
#	process_env(translation/R.Map.map_size+Vector2(1024,1024))
#	process_env()
	emit_signal("terrain_completed", [R.pos2grid(translation),mesh,shape])
#	print("thread end")

func terrain_complete(data):
	R.thread_count -= 1
#	print("thread end", translation)
	$Tile.mesh = data[1]
	$Tile/StaticBody/CollisionShape.shape = data[2]
	thread.wait_to_finish()
		
func _exit_tree():
#	print("exit tree")
#	loop_thread = false # Protect with Mutex.
#	semaphore.post()
	if thread.is_active():
		thread.wait_to_finish()

func fix_border(grid):
	print("obsolete, this is buggy")
#	if not R.ManMap.TerrainState == R.ManMap.State.COMPLETE:
#		return
	print("fixing border", grid)
	var mesh = $Tile.mesh
	if mesh == null:
		return
	var cmdt = MeshDataTool.new()
	var omdt = []
	cmdt.create_from_surface(mesh, 0)
	var down = {}
	var j = 0
	for tile in tile_offset:
		if R.Map.terrainNodes.has(grid+tile):
			omdt.append(MeshDataTool.new())
			var node = R.Map.terrainNodes[grid+tile]
			omdt[j].create_from_surface(node.get_node("Tile").mesh, 0)
			j += 1
		
	for i in omdt[0].get_vertex_count(): #Repeat for all four sides
		var v = omdt[0].get_vertex(i)
		if v.x == 0:
			down[v.z] = v.y
	for i in cmdt.get_vertex_count():
		var v = cmdt.get_vertex(i)
		if v.x == 1024:
			cmdt.set_vertex(i,Vector3(v.x,down[v.z],v.z))
			
	mesh.surface_remove(0)
	cmdt.commit_to_surface(mesh)
	$Tile.mesh = mesh
	
func process_env():
#	print("process environment is buggy")
	var from = translation/R.ManMap.map_size+Vector3(1024,0,1024)
	var to = from+Vector3(1024,0,1024)/R.ManMap.map_size
	
	for i in EnvItems.get_children(): #LOLtech
		i.queue_free()
#	var loc:Vector2 = Vector2(0,0)/4.5+Vector2(1024,1024)
	var pos
	for x in range(int(max(0,from.x)),int(min(2048,to.x))):
		for y in range(int(max(0,from.z)),int(min(2048,to.z))):
			var col:Color = R.Paint.envimg.get_pixelv(Vector2(x,y))
			if col.g > 0.5:
				pos = (Vector2(x,y)-Vector2(1024,1024))*4.5
				var ei =R.EnvItems[0][0].instance()
				EnvItems.add_child(ei)
				ei.translation = Vector3(pos.x+rand_range(-1,1),0,pos.y+rand_range(-1,1))
				R.FloorFinder.find_floor2(ei,true)
	
func create_tile_mesh(meshx, useheightmap = true):
	var mesh = meshx.duplicate() #should update existing mesh if one exists and also cache meshs
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	if useheightmap:
		for i in range(mdt.get_vertex_count()):
			var vertex = mdt.get_vertex(i)
			vertex.y = get_noise(Vector2(vertex.x, vertex.z))
#			vertex.y += noise.get_noise_2d((vertex.x+translation.x)/20, (vertex.z+translation.z)/20)*250
			mdt.set_vertex(i, vertex)
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	return mesh
	
func gen_normals(mesh):
#	var mesh = $Tile.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
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
	$Tile.mesh = mesh
	
	
#	return mesh

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
	

func get_noise(vec2):
	var vec_offset = Vector2(translation.x,translation.z)
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

func add_area(line,width=10):
	var midway = width_loc([line[1].translation,line[0].translation],width)
	var node = add_handle(midway)
	flatareas.append([line[0], line[1],width,node])
	process_area($Tile.mesh, [line[0].translation,line[1].translation],width,node)

func width_loc(line,width):
	var line_vec = (line[1]-line[0])/2
	var tang = Transform.looking_at(line_vec,Vector3.UP).basis.x
	return line[0]+line_vec+tang*width
	
	
func add_handle(loc):
	var handle = $MeshInstance.duplicate()
	$ControlNodes.add_child(handle)
	handle.owner = self
	handle.translation = loc
	handle.show()
	return handle

func update_handle(handle):
	print("terrain node update handle", handle)
	for i in flatareas:
		if i[3] == handle:
			var midway = width_loc([i[0].translation,i[1].translation],0)
			var dist = i[3].translation.distance_to(midway)
			i[2] = dist
	prev_level = -1
	
#	create_tile_mesh(R.Map.terrainMeshs[direction][level])
#	processs_all_areas()
#	process_env()
#	emit_signal("terrain_completed", R.pos2grid(translation))

func processs_all_areas(mesh):
	return
#	print("This area processing is buggy on borders")
#	FlatG.clear()
#	if not flatareas.empty():
#		for i in flatareas:
#			process_area(mesh, [i[0].translation,i[1].translation],i[2], i[3])

func process_area(mesh, line,width,node):
	return
#	node.translation = width_loc([line[0],line[1]],width)
#	line[0] = line[0]-translation
#	line[1] = line[1]-translation
#	var G = Geometry
##	var node = $Tile.Map.terrainNodes[Vector3(0,0,0)]
#	var line_vec = (line[1]-line[0]).normalized()
#	var dist = line[0].distance_to(line[1])
#	var tang = Transform.looking_at(line_vec,Vector3.UP).basis.x
#	var rs1 = line[0]+tang*width
#	var rs2 = line[0]-tang*width
#	var re1 = line[1]+tang*width
#	var re2 = line[1]-tang*width
#	var area:PoolVector3Array
#	area = [rs1,rs2,re1,re2]
#
#	FlatG.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
#	for p in area:
#		FlatG.add_vertex(p+Vector3(0,0.1,0))
#	FlatG.end()
#	return
	
#	if road_rect.size() == 6:
#		road_rect.remove(0)
#		road_rect.remove(0)
	#does not belong here, for POC
#	var rect:PoolVector2Array
#	rect.append(R.v3xz(area[0]))
#	rect.append(R.v3xz(area[1]))
#	rect.append(R.v3xz(area[2]))
#	rect.append(R.v3xz(area[3]))
#	rect.append(Vector2(road_rect[1].x,road_rect[1].z))
#	var rect1 = G.offset_polygon_2d(rect,20)
#	if not G.is_polygon_clockwise(rect):
#		var t = rect[0]
#		rect[0] = rect[1]
#		rect[1] = t
#	if not G.is_polygon_clockwise(rect):
#		print("***Potential problem not fixed")
#	else:
#		print("good")
#	print(rect)
	
#	var mesh = $Tile.mesh#.duplicate()
#	var mdt = MeshDataTool.new()
#	mdt.create_from_surface(mesh, 0)
#	for i in range(mdt.get_edge_count()):
#		var e0 = mdt.get_edge_vertex(i, 0)
#		var e1 = mdt.get_edge_vertex(i, 1)
#		var v0 = mdt.get_vertex(e0)
#		var v1 = mdt.get_vertex(e1)
#		var point = {}
#
#		for z in range(2):
#			for j in [[rs1,re1],[rs2,re2],[rs1,rs2],[re1,re2]]:
#				if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),R.v3xz(j[0]),R.v3xz(j[1])):
#					var y = G. get_closest_points_between_segments(v0,v1,j[0],j[1])[1].y
#					v0 = Vector3(v0.x,y,v0.z)
#					v1 = Vector3(v1.x,y,v1.z)
#					mdt.set_vertex(e0,v0)
#					mdt.set_vertex(e1,v1)
#
#		for z in range(3):
#			if G.is_point_in_polygon(R.v3xz(v0),rect) or G.is_point_in_polygon(R.v3xz(v1),rect):
#				var y0 = G.get_closest_point_to_segment(v0,line[0],line[1]).y
#				var y1 = G.get_closest_point_to_segment(v1,line[0],line[1]).y
#				v0 = Vector3(v0.x,y0,v0.z)
#				v1 = Vector3(v1.x,y1,v1.z)
#				mdt.set_vertex(e0,v0)
#				mdt.set_vertex(e1,v1)
#
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[0],rect[1]):
#			v0 = Vector3(v0.x,(road_rect[0]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[0]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
#		if G.segment_intersects_segment_2d(R.v3xz(v0),R.v3xz(v1),rect[2],rect[3]):
#			v0 = Vector3(v0.x,(road_rect[2]-node.translation).y,v0.z)
#			v1 = Vector3(v1.x,(road_rect[2]-node.translation).y,v1.z)
#			mdt.set_vertex(e0,v0)
#			mdt.set_vertex(e1,v1)
			
#	mesh.surface_remove(0)
#	mdt.commit_to_surface(mesh)
#	create_tile_mesh(mesh,false)
#	node.get_node("Tile").mesh = roadmesh
	
#	road_rect[0] = road_rect[road_rect.size()-2]
#	road_rect[1] = road_rect[road_rect.size()-1]
#	road_rect.resize(0)


func _on_Area_mouse_entered():
	print("mouse entered")
