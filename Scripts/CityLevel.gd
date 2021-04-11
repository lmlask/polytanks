extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		for j in range(10):
			var house = get_node("house").duplicate()
			house.translation.z += 15 * i
			house.translation.x += 15 * j
			add_child(house)
