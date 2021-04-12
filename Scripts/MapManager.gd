extends Spatial

onready var VM = $"../VehicleManager"
var maps = {}
var map = null
var maptiles = {}
var prev_tile
var tile_offset = [Vector3(0,0,0),Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1),Vector3(1,0,1),Vector3(-1,0,1),Vector3(1,0,-1),Vector3(-1,0,-1)]

func _ready():
	maps[0] = preload("res://Objects/TestLevel.tscn")
	maps[1] = preload("res://Objects/CityLevel.tscn")
	maps[2] = preload("res://Objects/hills map.tscn")
	load_map(0,Vector3.ZERO)

func clear_map():
	for mt in maptiles:
		maptiles[mt].queue_free()
	map = null
	maptiles.clear()	

func load_map(i,start_pos): #Need to add a location
	clear_map()
	map = i
	
	check_area((start_pos/1000).snapped(Vector3(1,1,1)))
#	map.get_node("DirectionalLight").show()
	
	#Dont expand on this. the map itself should do this
	if map == 1 and false: #fix later
		for i in range(10):
			for j in range(10):
				var house = map.get_node("house").duplicate()
				house.translation.z += 15 * i
				house.translation.x += 15 * j
				map.add_child(house)
#	if i == 2: 
#		var tile = maps[2].instance()
#		tile.translation += Vector3(1000,0,0)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(0,0,1000)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(-1000,0,0)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(0,0,-1000)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(1000,0,1000)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(-1000,0,1000)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(1000,0,-1000)
#		add_child(tile)
#		tile = maps[2].instance()
#		tile.translation += Vector3(-1000,0,-1000)
#		add_child(tile)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if map == null or not VM.vehicle is Node:
		return
	var cur_tile = (VM.vehicle.transform.origin/1000).snapped(Vector3(1,1,1))
	if not cur_tile == prev_tile:
		prev_tile = cur_tile
		check_area(cur_tile)
	
func check_area(center):
#	if not maptiles.has(center):
#		maptiles.append(center)
	for i in tile_offset:
		if not maptiles.has(center+i):
			var tile = maps[map].instance()
			maptiles[center+i] = tile
			tile.translation += (center+i)*1000
			add_child(tile)
