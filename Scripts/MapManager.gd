extends Spatial

var maps = {}
var map = null

func _ready():
	maps[0] = preload("res://Objects/TestLevel.tscn")
	maps[1] = preload("res://Objects/CityLevel.tscn")
	load_map(0)
	
func load_map(i):
	if not map == null:
		map.queue_free()
	map = maps[i].instance()
	add_child(map)
	
	#Dont expand on this
	if i == 1:
		for i in range(10):
			for j in range(10):
				var house = map.get_node("house").duplicate()
				house.translation.z += 15 * i
				house.translation.x += 15 * j
				map.add_child(house)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
