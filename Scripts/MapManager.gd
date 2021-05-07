extends Spatial
class_name MapMain

#onready var VM = $"../VehicleManager"
#var maps = {}
var map = null
var maptiles = {}
var maptiles_size = {}
var prev_tile = Vector3.INF
var tile_offset = [Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1),Vector3(1,0,1),Vector3(-1,0,1),Vector3(1,0,-1),Vector3(-1,0,-1)]
#var tran_offset = [[Vector3(1,0,2),Vector3(0,0,2),Vector3(-1,0,2)],[Vector3(2,0,1),Vector3(2,0,0),Vector3(2,0,-1)],
#					[Vector3(1,0,-2),Vector3(0,0,-2),Vector3(-1,0,-2)],[Vector3(-2,0,1),Vector3(-2,0,0),Vector3(-2,0,-1)]]
#var rough_offset = [Vector3(2,0,2),Vector3(-2,0,2),Vector3(2,0,-2),Vector3(-2,0,-2),
#					Vector3(1,0,3),Vector3(0,0,3),Vector3(-1,0,3),Vector3(3,0,1),Vector3(3,0,0),Vector3(3,0,-1),
#					Vector3(1,0,-3),Vector3(0,0,-3),Vector3(-1,0,-3),Vector3(-3,0,1),Vector3(-3,0,0),Vector3(-3,0,-1)]
#var tile_offset = [Vector3(0,0,1)]
#var tran_offset = [Vector3(0,0,2)]
#var rough_offset = [Vector3(0,0,3)]

#var mesh10:ArrayMesh = ArrayMesh.new()
#var mesh25:ArrayMesh = ArrayMesh.new()
#var mesh100:ArrayMesh = ArrayMesh.new()
#var MapNode = null #obsolete?
#var thread_update = Thread.new()
#var map_thread = Thread.new()
#var mutex = Mutex.new()
var fine_size = 16 #change array size
#var rough_size = 100
var map_size = 4
#var tilemesh = {} #Should be obsolete
var terrainMeshs = {0:[],1:[],2:[],3:[],4:[]} #Center
var terrainNodes = {}
enum State {START, TANK, MAP, COMPLETE}
var TerrainState = State.START

#var terrainTiles = {} #obsolete
#enum tileRes {ROUGH, FINE, A,B,C,D}#obsolete
var sites:Dictionary #0=Name
var sitesID:int = 0
var site_selected:int = -1
var items:Dictionary #0=Site ID, 1=Item ID, 2=Location, 3=Rotation
var itemsID:int = 0
var locations:Dictionary #0=Map, 1=Site ID, 2=Label, 3=Location, 4=Rotation
var locsID:int = 0
onready var LocsNode = $Locations
onready var ItemsNode = $Items
var buildings_added = false #change this


var time_of_day:float = 1.0
onready var env:Environment = $WorldEnvironment.environment

func _ready():
	load_files()
	env.background_energy = 1
	env.ambient_light_energy = 1
	$DirectionalLight.rotation.x = -0.5
	$DirectionalLight.light_energy = 1

	var terrain_size = fine_size
	for i in range(6): #change here
		terrainMeshs[0].append(create_mesh(terrain_size))
		terrainMeshs[1].append(create_tran_mesh(terrain_size, terrain_size*2)) #Correct
		terrainMeshs[2].append(rotate_mesh(terrainMeshs[1][i])) #Correct
		terrainMeshs[3].append(rotate_mesh(terrainMeshs[2][i])) #Correct
		terrainMeshs[4].append(rotate_mesh(terrainMeshs[3][i])) #Correct
		terrain_size = terrain_size*2

func load_files():
	var file = File.new()
	if not file.file_exists(R.sitesfile):
		return
	file.open(R.sitesfile, File.READ)
	sitesID = file.get_32()
	sites = file.get_var()
	file.close()
	if not file.file_exists(R.itemsfile):
		return
	file.open(R.itemsfile, File.READ)
	itemsID = file.get_32()
	items = file.get_var()
	file.close()
	if not file.file_exists(R.locsfile):
		return
	file.open(R.locsfile, File.READ)
	locsID = file.get_32()
	locations = file.get_var()
	file.close()
	
func create_tran_mesh(fine, rough):
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	var Idx = PoolIntArray()
	for i in range(0,1024+1,fine):
		vertices.push_back(Vector3(i, 0, 0))
		UVs.push_back(Vector2(i/1024.0, 0))
	for z in range(rough,1024+1,rough):
		for x in range(0,1024+1,rough):
			vertices.push_back(Vector3(x, 0, z))
			UVs.push_back(Vector2(x/1024.0, z/1024.0))
	var row = 1024/fine+1
	var rowr = 1024/rough+1
	var prev = row
#	print(vertices)
	for i in range(0,(1024/fine)):
		var v = row+round(float(i)*fine/rough)
		if not prev == v:
			Idx.push_back(i)
			Idx.push_back(v)
			Idx.push_back(prev)
			prev = v
		Idx.push_back(i)
		Idx.push_back(i+1)
		Idx.push_back(v)
	for y in range(0,(1024/rough)-1):
		for x in range(0,(1024/rough)):
			Idx.push_back(x+row+y*rowr)
			Idx.push_back(x+row+y*rowr+1)
			Idx.push_back(x+row+(y+1)*rowr)
			Idx.push_back(x+row+y*rowr+1)
			Idx.push_back(x+row+(y+1)*rowr+1)
			Idx.push_back(x+row+(y+1)*rowr)
#	print(Idx)
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = UVs
	arrays[ArrayMesh.ARRAY_INDEX] = Idx
	# Create the Mesh.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func rotate_mesh(meshx):
	var mesh = meshx.duplicate()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var vertex_uv = mdt.get_vertex_uv(i)
		mdt.set_vertex(i, Vector3(1024-vertex.z,0.0,vertex.x))
		mdt.set_vertex_uv(i, Vector2(1-vertex_uv.y,vertex_uv.x))
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	return mesh
	
func create_mesh(size)->ArrayMesh:
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	var Idx = PoolIntArray()
	for z in range(0,1024+1,size):
		for x in range(0,1024+1,size):
			vertices.push_back(Vector3(x, 0, z))
			UVs.push_back(Vector2(x/1024.0, z/1024.0))

	var row = 1024/size+1
	for y in range(0,(1024/size)):
		for x in range(0,(1024/size)):
#		if size == rough_size:
#			print(j,"-",row)
			Idx.push_back(x+y*row)
			Idx.push_back(x+y*row+1)
			Idx.push_back(x+(y+1)*row)
			Idx.push_back(x+y*row+1)
			Idx.push_back(x+(y+1)*row+1)
			Idx.push_back(x+(y+1)*row)

	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = UVs
	arrays[ArrayMesh.ARRAY_INDEX] = Idx
	# Create the Mesh.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
#	mutex.lock()
#	tilemesh[size] = mesh
#	mutex.unlock()
#	emit_signal("flat_terrain_completed")
	return mesh

func clear_map():
	for i in R.VPlayers.get_children():
		R.VPlayers.remove_child(i)
		i.free()
	for i in R.VWheeled.get_children():
		R.VWheeled.remove_child(i)
		i.queue_free()
	for i in R.VPlanes.get_children():
		R.VPlanes.remove_child(i)
		i.queue_free()
	for i in $Tiles.get_children():
		i.queue_free()
	map = null
	prev_tile = Vector3.INF
	maptiles.clear()
	maptiles_size.clear()
	terrainNodes.clear()
	TerrainState = State.START
	remove_locations()
	for _wait in range(10): #Bad solution to possibly fix a weird bug
		yield(get_tree(),"idle_frame")

func load_map(i,pos): #Need to add a location
	var grid = R.pos2grid(pos)
	clear_map()
	map = i
	R.load_image(map)
	process_tile(grid,0)
	add_items()
	

func process_tile(pos, level):
#	print(pos)
	var grid = R.pos2grid(pos)
	var MapNode = null
	if terrainNodes.has(grid):
		MapNode = terrainNodes[grid]
#		print(pos,grid)
	else:
		MapNode = R.terrain.instance() #only have the one map
		$Tiles.call_deferred("add_child",MapNode)
		var _err = MapNode.connect("terrain_completed", self, "terrain_complete", [], CONNECT_DEFERRED)
		terrainNodes[grid] = MapNode
		MapNode.set_pos(grid)
	MapNode.level = level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.EnvCycle:
		time_of_day += delta / 10
		time_of_day = wrapf(time_of_day,-0.25,PI+0.25)
		env.background_energy = max(0.01,sin(time_of_day))
		env.background_sky.sky_energy = max(0.01,sin(time_of_day))
		env.background_sky.ground_energy = max(0.01,sin(time_of_day))
		env.ambient_light_energy = max(0.005,sin(time_of_day))
		env.background_sky.sun_latitude = -rad2deg(time_of_day+PI)
		$DirectionalLight.rotation.x = -time_of_day
		$DirectionalLight.light_energy = max(0.0,sin(time_of_day))
	
	
func check_area(pos):
#	return
#	print("check_area ",pos)
	var grid = R.pos2grid(pos)
#	print(grid)
	if grid == prev_tile:
		return
	process_tile(pos,0)
	prev_tile = grid
#	print("process tiles")
	get_tree().call_group("terrain","update_tile",grid)
	
func terrain_complete(grid):
	if not TerrainState == State.COMPLETE:
		if TerrainState == State.START and GameState.InGame:
			TerrainState = State.TANK
			TerrainState = State.COMPLETE #Comment out to load full map
	#		print("resetting vehicle")
	#		pass
			R.ManVehicle.reset_tank(R.ManVehicle.vehicle) #maybe reset tank should be in a base class for all tanks
			for i in tile_offset:
#				process_tile(grid+i*1024,R.Map.terrainMeshs[0].size()-2)
				process_tile(grid+i*1024,1)
		if TerrainState == State.TANK:
			for x in range(-4,5): #
				for y in range(-4,5):
					if abs(x) > 1 or abs(y) > 1:
						process_tile(Vector3(x,0,y)*1024,R.Map.terrainMeshs[0].size()-1)
			TerrainState = State.MAP
		if	TerrainState == State.MAP:
			if $Tiles.get_child_count() == 81:
				TerrainState = State.COMPLETE
				get_tree().call_group("terrain","update_tile",R.pos2grid(GameState.view_location))
	for i in LocsNode.get_children():
#		print(i.name)
		if i.is_in_group("loc"):
			R.FloorFinder.find_floor2(i)
	for j in LocsNode.get_children():
		for i in j.get_node("Center").get_children():
#		for i in j.get_node("Center").get_children():
			if i.is_in_group("item"): #Fix this up, sort buildings/items or group them something better then "item"
				grid = (i.global_transform.origin/1000).snapped(Vector3(1,10,1))
				R.FloorFinder.find_floor2(i)



func show_locations():
	while LocsNode.get_child_count():
		yield(get_tree(),"idle_frame") #wait for nodes to clear
	for i in locations:
		if locations[i][0] == map:
			show_location(i)

func show_location(i):
	var sc = R.SiteCentre.instance()
	LocsNode.add_child(sc)
	sc.transform = Transform.IDENTITY
	sc.transform.origin = Vector3(locations[i][3].x,0,locations[i][3].y)
	sc.get_child(0).rotation.y = locations[i][4]
	while not sc.is_inside_tree():
		print("not in tree")
		yield(get_tree(),"idle_frame")
	sc.get_node("Center/CenterMesh").hide()
	sc.name = locations[i][2]+"-"+str(i)
	R.FloorFinder.find_floor2(sc)

func remove_locations():
	for i in LocsNode.get_children():
		i.queue_free()
		while is_instance_valid(i):
			yield(get_tree(),"idle_frame")
func remove_items():
	for i in ItemsNode.get_children():
		i.queue_free()
func locations_visibile(vis):
	for i in LocsNode.get_children():
		i.get_node("Center/CenterMesh").visible = vis
		

func update_locations():
	print_debug("obsolete")
	for i in LocsNode.get_children():
		var id = int(i.name.split("-")[1])
		locations[id].remove(3)
		locations[id].insert(3,Vector2(i.translation.x,i.translation.z))

func update_items():
	print_debug("obsolete")
	for i in ItemsNode.get_children():
		pass

func update_item(i):
	if i.is_in_group("item"):
		var lid = int(i.name.split("-")[1])
		var id = int(i.name.split("-")[2])
		print(lid,"-",id)
		items[id].remove(2)
#		items[id].insert(2,Vector2(i.translation.x-locations[lid][3].x,i.translation.z-locations[lid][3].y))
		items[id].insert(2,Vector2(i.translation.x,i.translation.z))
		items[id].remove(3)
		items[id].insert(3,i.get_child(0).rotation.y)
	if i.is_in_group("loc"):
		var id = int(i.name.split("-")[1])
		locations[id].remove(3)
		locations[id].insert(3,Vector2(i.translation.x,i.translation.z))
		locations[id].remove(4)
		locations[id].insert(4,i.get_child(0).rotation.y)
		print(locations[id])

func add_items():
	show_locations()
	for _wait in range(10):
		yield(get_tree(),"idle_frame")
	for l in locations:
		if locations[l][0] == map:
#			var lnode2 = LocsNode.get_node(locations[l][2]+"-"+str(l))
			var lnode = LocsNode.get_node(locations[l][2]+"-"+str(l)).get_node("Center")
#			print(lnode2, lnode)
			for i in items:
				if items[i][0] == locations[l][1]:
					var item = R.Items[items[i][1]]
					var node = item[0].instance()
					lnode.add_child(node)
					node.name = item[1]+"-"+str(l)+"-"+str(i)
					node.transform = Transform.IDENTITY
#					node.transform.origin = Vector3(items[i][2].x+locations[l][3].x,0,items[i][2].y+locations[l][3].y)
					node.transform.origin = Vector3(items[i][2].x,0,items[i][2].y)
					node.get_child(0).rotation.y = items[i][3]
					R.FloorFinder.find_floor2(node)
					
#					print(lnode)
#					for ln in LocsNode.get_children():
#						print(ln)
