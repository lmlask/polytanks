extends Node
class_name gameRoot

onready var VehicleManager = $VehicleManager
onready var NetworkManager = $NetworkManager

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
