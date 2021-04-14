extends Spatial
class_name MapMain

onready var VM = $"../VehicleManager"
var maps = {}
var map = null
var maptiles = {}
var prev_tile = Vector3.INF
var tile_offset = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1),Vector3(1,0,1),Vector3(-1,0,1),Vector3(1,0,-1),Vector3(-1,0,-1)]
var mesh10:ArrayMesh = ArrayMesh.new()
var mesh25:ArrayMesh = ArrayMesh.new()

func _ready():
	maps[0] = preload("res://Objects/TestLevel.tscn")
	maps[1] = preload("res://Objects/CityLevel.tscn")
	maps[2] = preload("res://Objects/hills map.tscn")
#	load_map(0,Vector3.ZERO)
	
	#Create a plane used for terrain
	mesh10 = create_mesh(10)
	mesh25 = create_mesh(25)
	
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
	return mesh

func clear_map():
	for mt in maptiles:
		maptiles[mt].queue_free()
	map = null
	prev_tile = Vector3.INF
	maptiles.clear()	

func load_map(i,pos): #Need to add a location
	clear_map()
	map = i
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
	pos.y = 0
	var center = (pos/1000).snapped(Vector3(1,10,1))
	if center == prev_tile:
		return
	prev_tile = center
	if large:
		for i in tile_offset: #too much for the moment
			add_tiles(center)
	else:
		add_tiles(center)

func add_tiles(pos):
	for i in tile_offset:
		if not maptiles.has(pos+i):
			var tile = maps[map].instance()
			maptiles[pos+i] = tile
			tile.translation += (pos+i)*1000-Vector3(500,0,500)
			add_child(tile)
			
