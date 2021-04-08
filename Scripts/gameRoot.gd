extends Node
class_name gameRoot

onready var VehicleManager = $VehicleManager
onready var NetworkManager = $NetworkManager

var timer = 0.0 #User for debug

func _ready():
	$Lobby.gameRoot = self
	$NetworkManager.intro = $Lobby
	VehicleManager.load_intro_tanks()
	
	for i in range(20):
		var house = $TestLevel/house.duplicate()
		house.translation.z += 15 * i
		$TestLevel.add_child(house)
	for i in range(20):
		var house = $TestLevel/house.duplicate()
		house.translation.x += 15 * i
		$TestLevel.add_child(house)

#Used for debug, comment out if needed
func _process(delta):
	timer += delta
	if timer > 1.0:
		timer -= 1.0
#		print("Role, ID ", GameState.roles)
#		print("Tank, ID ", GameState.DriverID)
