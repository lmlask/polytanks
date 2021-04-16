extends Spatial
class_name MapMain

onready var VM = $"../VehicleManager"
var maps = {}
var map = null
var maptiles = {}
var maptiles_size = {}
var prev_tile = Vector3.INF
var tile_offset = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1),Vector3(1,0,1),Vector3(-1,0,1),Vector3(1,0,-1),Vector3(-1,0,-1)]
var mesh10:ArrayMesh = ArrayMesh.new()
var mesh25:ArrayMesh = ArrayMesh.new()
var mesh100:ArrayMesh = ArrayMesh.new()
var tilemesh = {}
var MapNode = null
var thread_update = Thread.new()
var mutex = Mutex.new()
var fine_size = 5

var buildings_added = false #change this
#signal flat_terrain_completed

func _ready():
#	connect("flat_terrain_completed", self, "update_tiles")
	maps[0] = preload("res://Objects/TestLevel.tscn")
	maps[1] = preload("res://Objects/CityLevel.tscn")
	maps[2] = preload("res://Objects/hills map.tscn")
#	load_map(0,Vector3.ZERO)
	
	#Create a plane used for terrain
	var map_thread = Thread.new()
	map_thread.start(self,"create_mesh", fine_size)
	create_mesh(100)
	
func create_mesh(size)->ArrayMesh:
	var vertices = PoolVector3Array()
	for x in range(0,1000,size):
		for z in range(0,1000,size):
			vertices.push_back(Vector3(x, 0, z))
			vertices.push_back(Vector3(x+size, 0, z))
			vertices.push_back(Vector3(x, 0, z+size))
			vertices.push_back(Vector3(x+size, 0, z))
			vertices.push_back(Vector3(x+size, 0, z+size))
			vertices.push_back(Vector3(x, 0, z+size))
	# Initialize the ArrayMesh.
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	tilemesh[size] = mesh
#	emit_signal("flat_terrain_completed")
	return mesh

func clear_map():
	if MapNode:
		MapNode.queue_free()
	map = null
	prev_tile = Vector3.INF
	mutex.lock()
	maptiles.clear()
	maptiles_size.clear()
	mutex.unlock()
	thread_update.wait_to_finish()

func load_map(i,pos): #Need to add a location
	clear_map()
	map = 2
	MapNode = maps[map].instance()
	add_child(MapNode)
	generate_map(tilemesh[100])
	check_area(pos)
#	map.get_node("DirectionalLight").show()
	
	#Dont expand on this. the map itself should do this
	if map == 1 and false: #fix later
		for i in range(10):
			for j in range(10):
				var house = map.get_node("house").duplicate()
				house.translation.z += 15 * i
				house.translation.x += 15 * j
				map.add_child(house)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return #updated by camera
#	if map == null or not VM.vehicle is Node:
#		return
#	var cur_tile = (VM.vehicle.transform.origin/1000).snapped(Vector3(1,1,1))
#	if not cur_tile == prev_tile:
#		prev_tile = cur_tile
#		check_area(cur_tile)
	
func check_area(pos,large = false):
	var size = fine_size
	if not tilemesh.has(size):
		return
	pos.y = 0
	var center = (pos/1000).snapped(Vector3(1,10,1))
	if center == prev_tile:
		return
	prev_tile = center
	print("check pos ", center)
	for i in tile_offset:
		if not maptiles_size[center+i] == size:
			if not thread_update.is_active():
				thread_update.start(self, "update_tile", [center+i, size])
			else:
				prev_tile = Vector3.INF
#				print("thread running")

	
	yield(get_tree(),"idle_frame")
	for i in tile_offset:
		MapNode.add_sites(center+i)

func update_tile(data):
	var pos = data[0]
	var size = data[1]
	print("update", pos, "-", size)
	if not tilemesh.has(size):
		print("tile mesh not ready")
		prev_tile = Vector3.INF
		thread_update.call_deferred("wait_to_finish")
		return
	mutex.lock()
	maptiles_size[pos] = size
	mutex.unlock()
	MapNode.update_tile(pos,tilemesh[size],maptiles[pos])
	thread_update.call_deferred("wait_to_finish")
	

func add_tiles(pos,size = 100):
	for i in tile_offset:
		if not maptiles.has(pos+i):
			mutex.lock()
			maptiles_size[pos+i] = size
			maptiles[pos+i] =  MapNode.add_tile(pos+i,tilemesh[size])
			mutex.unlock()
		
func generate_map(mesh):
	for x in range(-5,5):
		for y in range(-5,5):
			var pos = Vector3(x,0,y)
			mutex.lock()
			maptiles_size[pos] = 100
			maptiles[pos] = MapNode.add_tile(pos,mesh)
			mutex.unlock()

func _exit_tree():
	thread_update.wait_to_finish()
