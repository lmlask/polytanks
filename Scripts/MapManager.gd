extends Spatial
class_name MapMain

#onready var VM = $"../VehicleManager"
#var maps = {}
var map = null
var maptiles = {}
var maptiles_size = {}
var prev_tile = Vector3.INF
var tile_offset = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1),Vector3(1,0,1),Vector3(-1,0,1),Vector3(1,0,-1),Vector3(-1,0,-1)]
var mesh10:ArrayMesh = ArrayMesh.new()
var mesh25:ArrayMesh = ArrayMesh.new()
var mesh100:ArrayMesh = ArrayMesh.new()
var MapNode = null
var thread_update = Thread.new()
var map_thread = Thread.new()
var mutex = Mutex.new()
var fine_size = 5
var rough_size = 250
var tilemesh = {}
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
signal terrain_completed


var time_of_day:float = 1.0
onready var env:Environment = $WorldEnvironment.environment

func _ready():
	load_files()
	env.background_energy = 1
	env.ambient_light_energy = 1
	$DirectionalLight.rotation.x = -0.5
	$DirectionalLight.light_energy = 1

	var _err = connect("terrain_completed", self, "terrain_complete", [], CONNECT_DEFERRED)
#	maps[0] = preload("res://Objects/TestLevel.tscn")
#	maps[1] = preload("res://Objects/CityLevel.tscn")
#	maps[2] = preload("res://Objects/hills map.tscn")
#	load_map(0,Vector3.ZERO)
	
	#Create a plane used for terrain
	map_thread.start(self,"create_mesh", fine_size)
	var _mesh = create_mesh(rough_size)

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
	
func create_mesh(size)->ArrayMesh:
	var vertices = PoolVector3Array()
	var UVs = PoolVector2Array()
	var Idx = PoolIntArray()
	for z in range(0,1000+1,size):
		for x in range(0,1000+1,size):
			vertices.push_back(Vector3(x, 0, z))
			UVs.push_back(Vector2(x/1000.0, z/1000.0))
#			vertices.push_back(Vector3(x+size, 0, z))
#			UVs.push_back(Vector2((x+size)/1000.0, z/1000.0))
#			vertices.push_back(Vector3(x, 0, z+size))
#			UVs.push_back(Vector2(x/1000.0, (z+size)/1000.0))
#			vertices.push_back(Vector3(x+size, 0, z))
#			UVs.push_back(Vector2((x+size)/1000.0, z/1000.0))
#			vertices.push_back(Vector3(x+size, 0, z+size))
#			UVs.push_back(Vector2((x+size)/1000.0, (z+size)/1000.0))
#			vertices.push_back(Vector3(x, 0, z+size))
#			UVs.push_back(Vector2(x/1000.0, (z+size)/1000.0))
	var row = 1000/size+1
	for y in range(0,(1000/size)):
		for x in range(0,(1000/size)):
#		if size == rough_size:
#			print(j,"-",row)
			Idx.push_back(x+y*row)
			Idx.push_back(x+y*row+1)
			Idx.push_back(x+(y+1)*row)
			Idx.push_back(x+y*row+1)
			Idx.push_back(x+(y+1)*row+1)
			Idx.push_back(x+(y+1)*row)
	# Initialize the ArrayMesh.
#	print(vertices)
#	print(UVs)
#	print(Idx)

	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = UVs
	arrays[ArrayMesh.ARRAY_INDEX] = Idx
	# Create the Mesh.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mutex.lock()
	tilemesh[size] = mesh
	mutex.unlock()
#	emit_signal("flat_terrain_completed")
	return mesh

func clear_map():
	if map_thread.is_active():
		map_thread.wait_to_finish()
	if thread_update.is_active():
		thread_update.wait_to_finish()
	if MapNode:
		remove_child(MapNode)
		MapNode.queue_free()
	for i in R.VTanks.get_children():
		R.VTanks.remove_child(i)
		i.free()
	for i in R.VWheeled.get_children():
		R.VWheeled.remove_child(i)
		i.queue_free()
	for i in R.VPlanes.get_children():
		R.VPlanes.remove_child(i)
		i.queue_free()
	map = null
	prev_tile = Vector3.INF
	mutex.lock()
	maptiles.clear()
	maptiles_size.clear()
	mutex.unlock()
#	remove_items()
	remove_locations()
	for _wait in range(10): #Bad solution to possibly fix a weird bug
		yield(get_tree(),"idle_frame")

func load_map(i,_pos): #Need to add a location
	clear_map()
	map = i
	MapNode = R.terrain.instance() #only have the one map
	call_deferred("add_child",MapNode)
#	generate_map(tilemesh[rough_size])
#	check_area(pos)
#	map.get_node("DirectionalLight").show()
	add_items()
	#Dont expand on this. the map itself should do this
#	if map == 1 and false: #fix later
#		for i in range(10):
#			for j in range(10):
#				var house = map.get_node("house").duplicate()
#				house.translation.z += 15 * i
#				house.translation.x += 15 * j
#				map.add_child(house)

	
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
	var size = fine_size
	if not tilemesh.has(size):
		return
	pos.y = 0
	var center = (pos/1000).snapped(Vector3(1,10,1))
	if center == prev_tile:
		return
	prev_tile = center
#	for j in tile_offset:
#		MapNode.add_sites(center+j)
	
	if not MapNode.img_loaded:
		return
#	return
	for i in tile_offset:
		if not maptiles.has(center+i):
			mutex.lock()
			maptiles_size[center+i] = rough_size
			maptiles[center+i] =  MapNode.add_tile(center+i,tilemesh[rough_size])
			mutex.unlock()
			prev_tile = Vector3.INF
			break
		if maptiles_size[center+i] == rough_size:
			if not thread_update.is_active() and GameState.InGame:
				thread_update.start(self, "update_tile", [center+i, size])
			else:
				prev_tile = Vector3.INF

func update_tile(data):
	var pos = data[0]
	var size = data[1]
#	print("update", pos, "-", size)
	if not tilemesh.has(size):
		print("tile mesh not ready")
		prev_tile = Vector3.INF
		thread_update.call_deferred("wait_to_finish")
		return
	mutex.lock()
	maptiles_size[pos] = size
	mutex.unlock()
	MapNode.update_tile(tilemesh[size],maptiles[pos])
	emit_signal("terrain_completed",pos)
	thread_update.call_deferred("wait_to_finish")
	
func terrain_complete(data):
#	print("terrain complete", data)
	var pos = R.ManVehicle.vehicle.global_transform.origin
	var grid = (pos/1000).snapped(Vector3(1,10,1))
	if data == grid:
		print("resetting vehicle")
		R.ManVehicle.reset_tank(R.ManVehicle.vehicle) #maybe reset tank should be in a base class for all tanks
	for i in LocsNode.get_children():
#		print(i.name)
		if i.is_in_group("loc"):
			R.FloorFinder.find_floor2(i)
	for j in LocsNode.get_children():
		for i in j.get_node("Center").get_children():
#		for i in j.get_node("Center").get_children():
			if i.is_in_group("item"): #Fix this up, sort buildings/items or group them something better then "item"
				grid = (i.global_transform.origin/1000).snapped(Vector3(1,10,1))
				if grid == data:
					R.FloorFinder.find_floor2(i)
#	for i in SitesNode.get_children():
#		R.FloorFinder.find_floor2(i)

#func add_tiles(pos,size = rough_size): #Not used?
#	print("is this used?")
#	for i in tile_offset:
#		if not maptiles.has(pos+i):
#			mutex.lock()
#			maptiles[pos+i] =  MapNode.add_tile(pos+i,tilemesh[size])
#			maptiles_size[pos+i] = size
#			mutex.unlock()
		
func generate_map(mesh):
	for x in range(-5,5):
		for y in range(-5,5):
			var pos = Vector3(x,0,y)
			mutex.lock()
			maptiles[pos] = MapNode.add_tile(pos,mesh)
			maptiles_size[pos] = rough_size
			mutex.unlock()

func _exit_tree():
	if thread_update.is_active():
		thread_update.wait_to_finish()

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
