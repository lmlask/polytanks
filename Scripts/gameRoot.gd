extends Node
class_name gameRoot

onready var VehicleManager = $VehicleManager
onready var NetworkManager = $NetworkManager
onready var Map = $Map
onready var GUI = $ViewportContainer/View/GUI

var timer = 0.0 #User for debug

func _ready():
	$Lobby.gameRoot = self
	$NetworkManager.intro = $Lobby
	R.Map.load_map(-1,Vector3.ZERO)
	yield(get_tree(),"idle_frame")
	R.ManVehicle.load_intro_tanks()
	R.Map.add_items()

#Used for debug, comment out if needed
func _process(delta):
	timer += delta
	if timer > 1.0:
		timer -= 1.0
#		print("Roles, ID ", GameState.roles)
#		print("Driver, ID ", GameState.DriverID)
#		print("hostingame", GameState.InGame,GameState.hostInGame)
#		print("map", GameState.map)
		
